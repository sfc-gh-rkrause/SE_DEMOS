/*--
 Retail Snowflake Intelligence with Snowflake Cortex - Setup Script
 This script creates all necessary objects for the Retail Snowflake Intelligence solution
--*/

USE ROLE accountadmin;

-- assign Query Tag to Session. This helps with performance monitoring and troubleshooting
ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"retail_intelligence","version":{"major":1,"minor":0},"attributes":{"is_quickstart":1,"source":"sql"}}';


-- Create custom role for Retail Snowflake Intelligence
CREATE OR REPLACE ROLE retail_snowflake_intelligence_role
    COMMENT = 'Role for Retail Snowflake Intelligence with AI_TRANSCRIBE and Cortex Agents';

-- Create warehouse for Retail Snowflake Intelligence
CREATE OR REPLACE WAREHOUSE retail_snowflake_intelligence_wh
    WAREHOUSE_SIZE = 'xsmall'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Retail Snowflake Intelligence with Cortex LLM';

-- Grant warehouse usage to custom role
GRANT USAGE ON WAREHOUSE retail_snowflake_intelligence_wh TO ROLE retail_snowflake_intelligence_role;
GRANT OPERATE ON WAREHOUSE retail_snowflake_intelligence_wh TO ROLE retail_snowflake_intelligence_role;

USE WAREHOUSE retail_snowflake_intelligence_wh;


-- Create database and schemas
CREATE DATABASE IF NOT EXISTS retail_snowflake_intelligence_db;
CREATE OR REPLACE SCHEMA retail_snowflake_intelligence_db.analytics;

-- Grant database and schema access to custom role
GRANT USAGE ON DATABASE retail_snowflake_intelligence_db TO ROLE retail_snowflake_intelligence_role;
GRANT USAGE ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT USAGE ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;

-- Grant create privileges on schemas
GRANT CREATE TABLE ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE VIEW ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE STAGE ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE FILE FORMAT ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE FUNCTION ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE TABLE ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE VIEW ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE STAGE ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE FILE FORMAT ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE FUNCTION ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT CREATE STREAMLIT ON SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;

-- Grant CORTEX_USER role for Cortex functions access
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE retail_snowflake_intelligence_role;

-- role hierarchy
GRANT ROLE retail_snowflake_intelligence_role TO ROLE sysadmin;

-- Create stages for data and audio files
CREATE OR REPLACE STAGE retail_snowflake_intelligence_db.analytics.semantic_models
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for call center audio files';

-- Grant stage access to custom role
GRANT READ ON STAGE retail_snowflake_intelligence_db.analytics.semantic_models TO ROLE retail_snowflake_intelligence_role;
GRANT WRITE ON STAGE retail_snowflake_intelligence_db.analytics.semantic_models TO ROLE retail_snowflake_intelligence_role;

GRANT READ ON STAGE retail_snowflake_intelligence_db.analytics.semantic_models TO ROLE retail_snowflake_intelligence_role;
GRANT WRITE ON STAGE retail_snowflake_intelligence_db.analytics.semantic_models TO ROLE retail_snowflake_intelligence_role;

-- Grant SELECT privileges on all tables for Cortex Analyst semantic models
GRANT SELECT ON ALL TABLES IN SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON ALL TABLES IN SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;

-- Grant SELECT privileges on all views for Cortex Analyst semantic models
GRANT SELECT ON ALL VIEWS IN SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA retail_snowflake_intelligence_db.public TO ROLE retail_snowflake_intelligence_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA retail_snowflake_intelligence_db.analytics TO ROLE retail_snowflake_intelligence_role;

-- snowflake intelligence setup
CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;

CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;

GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE retail_snowflake_intelligence_role;

/*--
 Furniture & Home - Idempotent Setup Script
 This script creates all tables, views, dynamic tables, and stored procedures
 for the Furniture & Home product analysis system.
 
 Prerequisites: setup.sql should be run first to create the necessary roles,
 warehouse, database, and permissions.
--*/

-- Use the retail database and warehouse
USE DATABASE retail_snowflake_intelligence_db;
USE WAREHOUSE retail_snowflake_intelligence_wh;
USE SCHEMA analytics;


-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Product reviews table
CREATE OR REPLACE TABLE product_reviews (
    product_id INT,
    product_name VARCHAR(100),
    product_description TEXT,
    review_title VARCHAR(150),
    review_text TEXT,
    rating INT,
    reviewer_name VARCHAR(100),
    review_date DATE,
    verified_purchase BOOLEAN,
    helpful_count INT DEFAULT 0,
    moderation_status VARCHAR(20),
    response_text TEXT,
    review_source VARCHAR(50)
);

-- Social media stream tables
CREATE OR REPLACE TABLE instagram_page_stream(record VARIANT);
CREATE OR REPLACE TABLE facebook_page_stream(record VARIANT);

-- Consolidated feedback table
CREATE OR REPLACE TABLE consolidated_feedback (
    product_name VARCHAR(100),
    comment_title VARCHAR(150),
    comment_text TEXT,
    commenter VARCHAR(100),
    comment_date DATE,
    comment_source VARCHAR(50)
);

-- Daily comment summary table (populated by stored procedure)
CREATE OR REPLACE TABLE DAILY_COMMENT_SUMMARY (
    PRODUCT_NAME VARCHAR(100),
    DAY DATE,
    SUMMARY TEXT,
    NUM_NEGATIVE_REVIEWS INT DEFAULT 0,
    NUM_POSITIVE_REVIEWS INT DEFAULT 0,
    TOTAL_SENTIMENT DOUBLE,
    AVERAGE_SENTIMENT FLOAT
);

-- Product comment stats table (populated by stored procedure)
CREATE OR REPLACE TABLE PRODUCT_COMMENT_STATS (
    PRODUCT_NAME VARCHAR(100),
    WEEK_START_DATE DATE,
    WEEK_NUMBER INT,  -- Week since launch (1, 2, 3, etc.)
    
    -- Volume metrics
    TOTAL_REVIEWS INT,
    TOTAL_POSITIVE_REVIEWS INT,
    TOTAL_NEGATIVE_REVIEWS INT,
    DAILY_REVIEW_AVG FLOAT,
    
    -- Sentiment metrics
    POSITIVE_REVIEW_RATIO FLOAT,  -- % of positive reviews
    AVG_SENTIMENT FLOAT,
    SENTIMENT_STDDEV FLOAT,       -- Standard deviation of sentiment
    
    -- Statistical comparison metrics
    SENTIMENT_P_VALUE FLOAT,
    SENTIMENT_PERCENTILE FLOAT,   -- How this furniture piece compares to all others at same week number
    SENTIMENT_Z_SCORE FLOAT,      -- Z-score compared to other furniture pieces at same week
    
    -- Time-based trends
    SENTIMENT_TREND FLOAT,        -- Slope of sentiment over the week
    TREND_P_VALUE FLOAT
);

-- Product sales table (populated by stored procedure)
CREATE OR REPLACE TABLE PRODUCT_SALES (
    PRODUCT_NAME VARCHAR(100),
    DAY DATE,
    DAILY_SALES_UNITS_ONLINE INTEGER,
    DAILY_SALES_UNITS_NORTHEAST INTEGER,
    DAILY_SALES_UNITS_NORTHWEST INTEGER,
    DAILY_SALES_UNITS_SOUTHEAST INTEGER,
    DAILY_SALES_UNITS_SOUTHWEST INTEGER,
    DAILY_SALES_UNITS_TOTAL INTEGER,
    LAUNCH_DATE DATE,
    DAYS_SINCE_LAUNCH INTEGER,
    SEASON varchar(20),
    IS_WEEKEND boolean,
    IS_HOLIDAY boolean,
    PROMOTION_ACTIVE boolean
);

-- Product sales analysis table (populated by stored procedure)
CREATE OR REPLACE TABLE PRODUCT_SALES_ANALYSIS (
    PRODUCT_NAME varchar(100) comment 'Name of the furniture piece',
    week_number integer comment 'Week number from launch',
    period_start_date DATE comment 'Start date of this analysis period',
    period_end_date DATE comment 'End date of this analysis period',
    TOTAL_SALES_UNITS_ONLINE INTEGER comment 'Total sales during this period online',
    TOTAL_SALES_UNITS_NORTHEAST INTEGER comment 'Total sales during this period in the Northeast',
    TOTAL_SALES_UNITS_NORTHWEST INTEGER comment 'Total sales during this period in the Northwest',
    TOTAL_SALES_UNITS_SOUTHEAST INTEGER comment 'Total sales during this period in the Southeast',
    TOTAL_SALES_UNITS_SOUTHWEST INTEGER comment 'Total sales during this period in the Southwest',
    TOTAL_SALES_UNITS INTEGER comment 'Total sales during this period',
    AVG_DAILY_UNITS_ONLINE float comment 'Average daily sales during this period online',
    AVG_DAILY_UNITS_NORTHEAST float comment 'Average daily sales during this period in Northeast',
    AVG_DAILY_UNITS_NORTHWEST float comment 'Average daily sales during this period in Northwest',
    AVG_DAILY_UNITS_SOUTHEAST float comment 'Average daily sales during this period in Southeast',
    AVG_DAILY_UNITS_SOUTHWEST float comment 'Average daily sales during this period in Southwest',
    AVG_DAILY_UNITS_TOTAL float comment 'Average total daily sales during this period',
    sales_growth float comment 'Growth rate compared to previous period',
    cumulative_sales_units integer comment 'Total sales since launch through this period',
    zscore double comment 'Z-score compared to historical furniture pieces at same period',
    percentile double comment 'Percentile ranking among all furniture pieces for this period',
    pct_25 double comment '25th percentile value for this period across all furniture pieces',
    pct_50 double comment '50th percentile (median) value for this period',
    pct_75 double comment '75th percentile value for this period',
    pct_90 double comment '90th percentile value for this period',
    ttest_pvalue double comment 'P-value from t-test comparing to historical data',
    is_significant BOOLEAN comment 'Whether difference is statistically significant (p < 0.05)',
    comparative_lift double comment 'Percentage difference from average historical performance'
);

-- Product inventory table
CREATE OR REPLACE TABLE product_inventory (
    product_name VARCHAR(100) NOT NULL,
    units_available_online INTEGER NOT NULL,
    units_available_northeast INTEGER NOT NULL,
    units_available_southeast INTEGER NOT NULL,
    units_available_southwest INTEGER NOT NULL,
    units_available_northwest INTEGER NOT NULL,
    inventory_as_of_date DATE
);

-- =============================================================================
-- DYNAMIC TABLES
-- =============================================================================

-- Facebook posts dynamic table
CREATE OR REPLACE DYNAMIC TABLE facebook_posts
 (id, post_time, from_id, from_name, message)
TARGET_LAG = DOWNSTREAM
warehouse = retail_snowflake_intelligence_wh
AS
select posts.value:id::string as id, 
       to_timestamp_tz(posts.value:created_time::string, 'YYYY-MM-DDTHH24:MI:SSTZHTZM') as post_time,
       posts.value:from.id::string as from_id,
       posts.value:from.name::string as from_name,
       posts.value:message::string as message
from facebook_page_stream f,
     lateral FLATTEN(INPUT => f.record:data) posts;

-- Instagram posts dynamic table
CREATE OR REPLACE DYNAMIC TABLE instagram_posts
 (id, post_time, from_name, message)
TARGET_LAG = DOWNSTREAM
warehouse = retail_snowflake_intelligence_wh
AS
select posts.value:id::string as id, 
       to_timestamp_tz(posts.value:timestamp::string, 'YYYY-MM-DDTHH24:MI:SSTZHTZM') as post_time,
       posts.value:username::string as from_name,
       posts.value:text::string as message
from instagram_page_stream f,
     lateral FLATTEN(INPUT => f.record:data) posts;

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Enriched feedback view with sentiment analysis
CREATE OR REPLACE VIEW enriched_feedback AS
SELECT *, 
       SNOWFLAKE.CORTEX.SENTIMENT(comment_title||' '||comment_text) as sentiment,
       trim(SNOWFLAKE.CORTEX.CLASSIFY_TEXT(comment_title||' '||comment_text, 
           ['Design', 'Quality', 'Comfort', 'Price', 'Shipping'])['label'], '"') as topic
FROM consolidated_feedback;

-- =============================================================================
-- STORED PROCEDURES FOR DATA GENERATION
-- =============================================================================

-- Stored procedure to generate daily comment summary data
CREATE OR REPLACE PROCEDURE generate_daily_comment_summary()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy', 'faker')
HANDLER = 'main'
AS
$$
import pandas as pd
import numpy as np
from datetime import date, datetime, timedelta
import random
from faker import Faker

def main(session):
    # Set random seed for reproducibility
    np.random.seed(42)
    random.seed(42)
    fake = Faker()
    Faker.seed(42)

    # Define the furniture names
    furniture_names = [
        "Executive Oak Desk",
        "Modern Sectional Sofa",
        "Rustic Dining Table",
        "Ergonomic Office Chair",
        "Industrial Bookshelf",
        "Scandinavian Coffee Table",
        "Memory Foam Mattress",
        "Vintage Leather Armchair",
        "Glass Top End Table",
        "Upholstered Storage Bench",
        "Adjustable Standing Desk",
        "Velvet Accent Chair"
    ]

    # "Current" date for reference
    current_date = date(2025, 6, 23)

    # Staggered launch dates over the last 2 years
    launch_dates = {}
    two_years_ago = current_date - timedelta(days=2*365)

    # Generate staggered launch dates (oldest to newest)
    ordered_launches = [
        "Executive Oak Desk",
        "Modern Sectional Sofa",
        "Rustic Dining Table",
        "Ergonomic Office Chair",
        "Industrial Bookshelf",
        "Scandinavian Coffee Table",
        "Memory Foam Mattress",
        "Vintage Leather Armchair",
        "Glass Top End Table",
        "Upholstered Storage Bench",
        "Adjustable Standing Desk",
        "Velvet Accent Chair"
    ]

    for i, furniture in enumerate(ordered_launches):
        days_offset = int(i * (2*365) / len(ordered_launches))
        launch_dates[furniture] = two_years_ago + timedelta(days=days_offset)

    launch_dates["Adjustable Standing Desk"] = date(2025, 6, 17)
    launch_dates["Velvet Accent Chair"] = date(2025, 6, 17)

    # Define comment templates for summary generation
    positive_templates = [
        "Customers love the {furniture} design, praising its {adj1} construction and {adj2} build quality.",
        "Reviews highlight {furniture}'s {adj1} craftsmanship and {adj2} comfort features.",
        "Many users comment on how {furniture} fits {adj1} in their space and feels {adj2}.",
        "Positive feedback emphasizes {furniture}'s {adj1} style that {verb} any room perfectly.",
        "{furniture} receives praise for its {adj1} materials and {adj2} functionality."
    ]

    negative_templates = [
        "Some customers find {furniture}'s assembly too {adj1} and the quality {adj2}.",
        "A few reviews mention {furniture} arrived with {adj1} damage during shipping.",
        "Negative comments note {furniture}'s {verb} too quickly after purchase.",
        "Criticism of {furniture} centers on its {adj1} construction and {adj2} durability.",
        "Some users reported {furniture} has a {adj1} feel and {adj2} comfort level."
    ]

    neutral_templates = [
        "Mixed reviews for {furniture}, with some loving its {adj1} qualities while others find it {adj2}.",
        "{furniture} generates divided opinions: praise for its {adj1} aspects but concerns about {adj2} properties.",
        "Feedback on {furniture} varies between appreciation for its {adj1} design and critiques of its {adj2} assembly process.",
        "Customers have conflicting views on {furniture}, with both {adj1} supporters and those who find it {adj2}.",
        "{furniture} has polarized reactions, with comments split between {adj1} experiences and {adj2} disappointments."
    ]

    positive_adjectives = ["sturdy", "elegant", "comfortable", "well-built", "beautiful", "practical", "spacious", "durable"]
    negative_adjectives = ["flimsy", "uncomfortable", "cheaply-made", "unstable", "disappointing", "cramped", "poorly-designed", "overpriced"]
    positive_verbs = ["transforms", "enhances", "complements", "elevates", "beautifies"]
    negative_verbs = ["breaks", "wobbles", "disappoints", "fails", "deteriorates"]

    # Function to generate a summary based on sentiment
    def generate_summary(furniture, sentiment):
        if sentiment > 0.5:  # Very positive
            template = random.choice(positive_templates)
            adj1 = random.choice(positive_adjectives)
            adj2 = random.choice(positive_adjectives)
            verb = random.choice(positive_verbs)
        elif sentiment > 0:  # Somewhat positive
            template = random.choice([*positive_templates, *neutral_templates])
            adj1 = random.choice(positive_adjectives)
            adj2 = random.choice([*positive_adjectives, *negative_adjectives])
            verb = random.choice([*positive_verbs, *negative_verbs])
        elif sentiment > -0.5:  # Somewhat negative
            template = random.choice([*negative_templates, *neutral_templates])
            adj1 = random.choice([*positive_adjectives, *negative_adjectives])
            adj2 = random.choice(negative_adjectives)
            verb = random.choice([*positive_verbs, *negative_verbs])
        else:  # Very negative
            template = random.choice(negative_templates)
            adj1 = random.choice(negative_adjectives)
            adj2 = random.choice(negative_adjectives)
            verb = random.choice(negative_verbs)
        
        return template.format(furniture=furniture, adj1=adj1, adj2=adj2, verb=verb)

    # Create empty list to store our data
    data = []

    for furniture in furniture_names:
        launch_date = launch_dates[furniture]
        current_date_ptr = launch_date

        # Each furniture piece has a baseline popularity and sentiment
        baseline_popularity = random.uniform(10, 50)
        baseline_sentiment = random.uniform(-0.2, 0.8)

        # Add a trend component (some furniture trends up, some down)
        trend = random.uniform(-0.01, 0.01)

        # manually fix up the one we want to be trending
        if (furniture == "Velvet Accent Chair"):
            baseline_popularity = 60
            baseline_sentiment = 0.833
            trend = random.uniform(0.01, 0.03)
        
        # Generate data from launch until current date
        while current_date_ptr <= current_date:
            # Calculate time-based factors
            day_of_week = current_date_ptr.weekday()
            weekend_boost = 1.2 if day_of_week >= 5 else 1.0
            
            # Simulate seasonal preference
            seasonal_boost = 1.0
            month = current_date_ptr.month
            
            # Seasonal adjustments
            if month in [3, 4, 5] and furniture in ["Memory Foam Mattress", "Glass Top End Table", "Upholstered Storage Bench"]:
                seasonal_boost = 1.3
            elif month in [6, 7, 8] and furniture in ["Scandinavian Coffee Table", "Adjustable Standing Desk", "Velvet Accent Chair"]:
                seasonal_boost = 1.3
            elif month in [9, 10, 11] and furniture in ["Executive Oak Desk", "Modern Sectional Sofa", "Rustic Dining Table"]:
                seasonal_boost = 1.3
            elif month in [12, 1, 2] and furniture in ["Ergonomic Office Chair", "Industrial Bookshelf", "Vintage Leather Armchair"]:
                seasonal_boost = 1.3
            
            # Calculate total reviews for the day
            day_offset = (current_date_ptr - launch_date).days
            total_reviews = max(1, int(baseline_popularity * weekend_boost * seasonal_boost * (1 + trend * day_offset) * random.uniform(0.8, 1.2)))
            
            # Calculate sentiment for the day
            day_sentiment = min(1.0, max(-1.0, baseline_sentiment + trend * day_offset + random.uniform(-0.2, 0.2)))
            
            # Calculate positive vs negative reviews
            ratio_positive = (day_sentiment + 1) / 2
            num_positive = int(total_reviews * ratio_positive)
            num_negative = total_reviews - num_positive
            
            # Generate summary
            summary = generate_summary(furniture, day_sentiment)
            
            # Add to data list
            data.append({
                'PRODUCT_NAME': furniture,
                'DAY': current_date_ptr,
                'SUMMARY': summary,
                'NUM_NEGATIVE_REVIEWS': num_negative,
                'NUM_POSITIVE_REVIEWS': num_positive,
                'TOTAL_SENTIMENT': round(day_sentiment * total_reviews, 2),
                'AVERAGE_SENTIMENT': round(day_sentiment, 2)
            })

            # Move to next day
            current_date_ptr += timedelta(days=1)

    # Convert to DataFrame
    df = pd.DataFrame(data)
    df = df.sort_values(by=['DAY'])

    # Clear existing data and write new data
    session.sql("TRUNCATE TABLE DAILY_COMMENT_SUMMARY").collect()
    session.write_pandas(df, 'DAILY_COMMENT_SUMMARY')

    return f"Data successfully generated and inserted into DAILY_COMMENT_SUMMARY: {len(df)} records"
$$;

-- Stored procedure to generate product comment stats
CREATE OR REPLACE PROCEDURE generate_product_comment_stats()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy', 'scipy')
HANDLER = 'main'
AS
$$
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
try:
    from scipy import stats
except ImportError:
    # Fallback if scipy not available
    stats = None

def main(session):
    # Read data from DAILY_COMMENT_SUMMARY
    df = session.table("DAILY_COMMENT_SUMMARY").to_pandas().sort_values(by=['PRODUCT_NAME', 'DAY'])
    
    # Function to identify launch date for each furniture piece
    def get_launch_dates(df):
        launch_dates = {}
        for product in df['PRODUCT_NAME'].unique():
            product_data = df[df['PRODUCT_NAME'] == product]
            launch_date = product_data['DAY'].min()
            launch_dates[product] = launch_date
        return launch_dates

    # Calculate week number since launch for each record
    def add_week_since_launch(df, launch_dates):
        def get_week_number(row):
            launch = launch_dates[row['PRODUCT_NAME']]
            days_since_launch = (row['DAY'] - launch).days
            return days_since_launch // 7 + 1  # Week 1 is the first week
        
        df['WEEK_NUMBER'] = df.apply(get_week_number, axis=1)
        return df

    # Group data by furniture piece and week number
    def get_weekly_stats(df):
        df['TOTAL_REVIEWS'] = df['NUM_NEGATIVE_REVIEWS'] + df['NUM_POSITIVE_REVIEWS']
        df['POSITIVE_REVIEW_RATIO'] = df['NUM_POSITIVE_REVIEWS'] / df['TOTAL_REVIEWS'].replace(0, np.nan)
        
        weekly_stats = df.groupby(['PRODUCT_NAME', 'WEEK_NUMBER']).agg(
            WEEK_START_DATE=('DAY', lambda x: x.min()),
            TOTAL_REVIEWS=('TOTAL_REVIEWS', 'sum'),
            TOTAL_POSITIVE_REVIEWS=('NUM_POSITIVE_REVIEWS', 'sum'),
            TOTAL_NEGATIVE_REVIEWS=('NUM_NEGATIVE_REVIEWS', 'sum'),
            DAILY_REVIEW_AVG=('TOTAL_REVIEWS', 'mean'),
            POSITIVE_REVIEW_RATIO=('POSITIVE_REVIEW_RATIO', 'mean'),
            AVG_SENTIMENT=('AVERAGE_SENTIMENT', 'mean'),
            SENTIMENT_STDDEV=('AVERAGE_SENTIMENT', 'std'),
        ).reset_index()
        
        # Calculate sentiment trend for each week
        weekly_stats['SENTIMENT_TREND'] = np.nan
        weekly_stats['TREND_P_VALUE'] = np.nan
        
        if stats:
            for product in weekly_stats['PRODUCT_NAME'].unique():
                for week in weekly_stats[weekly_stats['PRODUCT_NAME'] == product]['WEEK_NUMBER']:
                    mask = (df['PRODUCT_NAME'] == product) & (df['WEEK_NUMBER'] == week)
                    week_data = df[mask].sort_values('DAY')
                    
                    if len(week_data) >= 3:
                        x = np.array(range(len(week_data)))
                        y = week_data['AVERAGE_SENTIMENT'].values
                        slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
                        
                        idx = ((weekly_stats['PRODUCT_NAME'] == product) & 
                               (weekly_stats['WEEK_NUMBER'] == week))
                        weekly_stats.loc[idx, 'SENTIMENT_TREND'] = slope
                        weekly_stats.loc[idx, 'TREND_P_VALUE'] = p_value
        
        return weekly_stats

    # Calculate statistical comparisons
    def add_statistical_comparisons(weekly_stats):
        weekly_stats['SENTIMENT_PERCENTILE'] = np.nan
        weekly_stats['SENTIMENT_Z_SCORE'] = np.nan
        weekly_stats['SENTIMENT_P_VALUE'] = np.nan
        
        for week in weekly_stats['WEEK_NUMBER'].unique():
            week_data = weekly_stats[weekly_stats['WEEK_NUMBER'] == week]
            sentiments = week_data['AVG_SENTIMENT'].dropna()
            
            if len(sentiments) <= 1:
                continue
                
            mean_sentiment = sentiments.mean()
            std_sentiment = sentiments.std()
            
            if std_sentiment == 0:
                std_sentiment = 0.0001
                
            for idx, row in week_data.iterrows():
                if pd.notna(row['AVG_SENTIMENT']):
                    # Calculate percentile
                    if stats:
                        percentile = stats.percentileofscore(sentiments, row['AVG_SENTIMENT']) / 100
                        weekly_stats.loc[idx, 'SENTIMENT_PERCENTILE'] = percentile
                    
                    # Calculate Z-score
                    z_score = (row['AVG_SENTIMENT'] - mean_sentiment) / std_sentiment
                    weekly_stats.loc[idx, 'SENTIMENT_Z_SCORE'] = z_score
                    
                    # Simple p-value approximation if scipy available
                    if stats and len(sentiments) >= 2:
                        try:
                            other_sentiments = sentiments[sentiments.index != idx].values
                            if len(other_sentiments) > 0:
                                t_stat, p_value = stats.ttest_1samp(other_sentiments, row['AVG_SENTIMENT'])
                                weekly_stats.loc[idx, 'SENTIMENT_P_VALUE'] = p_value
                        except:
                            pass
        
        return weekly_stats

    # Process the data
    launch_dates = get_launch_dates(df)
    df = add_week_since_launch(df, launch_dates)
    weekly_stats = get_weekly_stats(df)
    final_stats = add_statistical_comparisons(weekly_stats)
    
    # Prepare final data
    final_data = final_stats[['PRODUCT_NAME', 'WEEK_START_DATE', 'WEEK_NUMBER', 
                             'TOTAL_REVIEWS', 'TOTAL_POSITIVE_REVIEWS', 'TOTAL_NEGATIVE_REVIEWS',
                             'DAILY_REVIEW_AVG', 'POSITIVE_REVIEW_RATIO', 'AVG_SENTIMENT', 
                             'SENTIMENT_STDDEV', 'SENTIMENT_PERCENTILE', 'SENTIMENT_Z_SCORE', 
                             'SENTIMENT_P_VALUE', 'SENTIMENT_TREND', 'TREND_P_VALUE']]

    # Clear existing data and write new data
    session.sql("TRUNCATE TABLE PRODUCT_COMMENT_STATS").collect()
    session.write_pandas(final_data, 'PRODUCT_COMMENT_STATS')

    return f"Successfully generated product comment statistics: {len(final_data)} records"
$$;

-- Stored procedure to generate product sales data
CREATE OR REPLACE PROCEDURE generate_product_sales()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy', 'faker')
HANDLER = 'main'
AS
$$
import pandas as pd
import numpy as np
from datetime import datetime, timedelta, date
import random
from faker import Faker

def main(session):
    # Set random seed for reproducibility
    np.random.seed(42)
    random.seed(42)
    fake = Faker()
    Faker.seed(42)

    # Define the furniture names
    furniture_names = [
        "Executive Oak Desk",
        "Modern Sectional Sofa", 
        "Rustic Dining Table",
        "Ergonomic Office Chair",
        "Industrial Bookshelf",
        "Scandinavian Coffee Table",
        "Memory Foam Mattress",
        "Vintage Leather Armchair",
        "Glass Top End Table",
        "Upholstered Storage Bench",
        "Adjustable Standing Desk",
        "Velvet Accent Chair"
    ]

    # Define seasonality preferences for each furniture piece
    seasonality = {
        "Memory Foam Mattress": {"spring": 1.5, "summer": 1.2, "fall": 0.9, "winter": 0.8},
        "Glass Top End Table": {"spring": 1.3, "summer": 1.4, "fall": 0.8, "winter": 0.7},
        "Upholstered Storage Bench": {"spring": 1.4, "summer": 1.1, "fall": 1.0, "winter": 0.8},
        "Scandinavian Coffee Table": {"spring": 1.2, "summer": 1.5, "fall": 1.0, "winter": 0.7},
        "Adjustable Standing Desk": {"spring": 1.1, "summer": 1.4, "fall": 0.9, "winter": 0.7},
        "Velvet Accent Chair": {"spring": 1.0, "summer": 1.4, "fall": 1.1, "winter": 0.7},
        "Executive Oak Desk": {"spring": 0.9, "summer": 1.3, "fall": 1.2, "winter": 0.8},
        "Modern Sectional Sofa": {"spring": 0.8, "summer": 0.9, "fall": 1.6, "winter": 1.1},
        "Rustic Dining Table": {"spring": 0.8, "summer": 0.8, "fall": 1.5, "winter": 1.2},
        "Ergonomic Office Chair": {"spring": 0.7, "summer": 0.8, "fall": 1.4, "winter": 1.3},
        "Industrial Bookshelf": {"spring": 0.8, "summer": 0.7, "fall": 1.1, "winter": 1.6},
        "Vintage Leather Armchair": {"spring": 0.9, "summer": 0.8, "fall": 1.2, "winter": 0.8}
    }

    # Define characteristics for each furniture piece
    furniture_characteristics = {
        "Memory Foam Mattress": {"base_popularity": 100, "growth_trend": 0.02, "volatility": 0.15},
        "Glass Top End Table": {"base_popularity": 90, "growth_trend": 0.01, "volatility": 0.12},
        "Upholstered Storage Bench": {"base_popularity": 85, "growth_trend": 0.015, "volatility": 0.14},
        "Scandinavian Coffee Table": {"base_popularity": 110, "growth_trend": 0.025, "volatility": 0.11},
        "Adjustable Standing Desk": {"base_popularity": 80, "growth_trend": 0.01, "volatility": 0.11},
        "Velvet Accent Chair": {"base_popularity": 90, "growth_trend": 0.02, "volatility": 0.13},
        "Executive Oak Desk": {"base_popularity": 105, "growth_trend": 0.005, "volatility": 0.16},
        "Modern Sectional Sofa": {"base_popularity": 115, "growth_trend": 0.01, "volatility": 0.14},
        "Rustic Dining Table": {"base_popularity": 95, "growth_trend": 0.015, "volatility": 0.13},
        "Ergonomic Office Chair": {"base_popularity": 85, "growth_trend": 0.005, "volatility": 0.17},
        "Industrial Bookshelf": {"base_popularity": 90, "growth_trend": 0.02, "volatility": 0.12},
        "Vintage Leather Armchair": {"base_popularity": 90, "growth_trend": 0.025, "volatility": 0.11}
    }

    # Current date and launch dates
    current_date = date(2025, 6, 23)
    two_years_ago = current_date - timedelta(days=2*365)

    ordered_launches = [
        "Executive Oak Desk", "Modern Sectional Sofa", "Rustic Dining Table", "Ergonomic Office Chair",
        "Industrial Bookshelf", "Scandinavian Coffee Table", "Memory Foam Mattress", "Vintage Leather Armchair",
        "Glass Top End Table", "Upholstered Storage Bench", "Adjustable Standing Desk", "Velvet Accent Chair"
    ]

    launch_dates = {}
    for i, furniture in enumerate(ordered_launches):
        days_offset = int(i * (2*365) / len(ordered_launches))
        launch_dates[furniture] = two_years_ago + timedelta(days=days_offset)

    launch_dates["Adjustable Standing Desk"] = date(2025, 6, 17)
    launch_dates["Velvet Accent Chair"] = date(2025, 6, 17)

    # Helper functions
    def get_season(date):
        month = date.month
        if month in [3, 4, 5]: return "spring"
        elif month in [6, 7, 8]: return "summer"
        elif month in [9, 10, 11]: return "fall"
        else: return "winter"

    def get_random_sales(mean_daily_sales, volatility):
        daily_sales = int(np.random.normal(mean_daily_sales, mean_daily_sales * volatility))
        return round(max(daily_sales, 0))

    def simulate_sales(furniture, date, days_since_launch):
        base = furniture_characteristics[furniture]["base_popularity"]
        growth = furniture_characteristics[furniture]["growth_trend"]
        volatility = furniture_characteristics[furniture]["volatility"]
        
        season = get_season(date)
        seasonal_factor = seasonality[furniture][season]
        
        day_of_week = date.weekday()
        weekend_factor = 1.3 if day_of_week >= 5 else 1.0
        
        holiday_factor = 1.5 if random.random() < 0.03 else 1.0
        
        if days_since_launch < 30:
            launch_factor = 1.4 - (0.4 * days_since_launch / 30)
        else:
            launch_factor = 1.0
        
        promotion_active = random.random() < 0.1
        promotion_factor = 1.4 if promotion_active else 1.0
        
        time_factor = 1.0 + (growth * days_since_launch / 30)
        
        mean_daily_sales = base * seasonal_factor * weekend_factor * holiday_factor * launch_factor * promotion_factor * time_factor
        
        daily_sales_online = get_random_sales(mean_daily_sales, volatility)
        daily_sales_northeast = get_random_sales(mean_daily_sales, volatility)
        daily_sales_northwest = get_random_sales(mean_daily_sales, volatility)
        daily_sales_southeast = get_random_sales(mean_daily_sales, volatility)
        daily_sales_southwest = get_random_sales(mean_daily_sales, volatility)
        daily_sales = daily_sales_online + daily_sales_northeast + daily_sales_northwest + daily_sales_southeast + daily_sales_southwest
        
        return {
            "daily_sales_online": daily_sales_online,
            "daily_sales_northeast": daily_sales_northeast,
            "daily_sales_northwest": daily_sales_northwest,
            "daily_sales_southeast": daily_sales_southeast,
            "daily_sales_southwest": daily_sales_southwest,
            "daily_sales": daily_sales,
            "season": season,
            "is_weekend": day_of_week >= 5,
            "is_holiday": holiday_factor > 1.0,
            "promotion_active": promotion_active
        }

    # Create the sales data
    sales_data = []

    for furniture in furniture_names:
        launch_date = launch_dates[furniture]
        current_date_ptr = launch_date
        
        while current_date_ptr <= current_date:
            days_since_launch = (current_date_ptr - launch_date).days
            sales_info = simulate_sales(furniture, current_date_ptr, days_since_launch)
            
            sales_data.append({
                "DAY": current_date_ptr,
                "PRODUCT_NAME": furniture,
                "DAILY_SALES_UNITS_ONLINE": sales_info["daily_sales_online"],
                "DAILY_SALES_UNITS_NORTHEAST": sales_info["daily_sales_northeast"],
                "DAILY_SALES_UNITS_NORTHWEST": sales_info["daily_sales_northwest"],
                "DAILY_SALES_UNITS_SOUTHEAST": sales_info["daily_sales_southeast"],
                "DAILY_SALES_UNITS_SOUTHWEST": sales_info["daily_sales_southwest"],
                "DAILY_SALES_UNITS_TOTAL": sales_info["daily_sales"],
                "LAUNCH_DATE": launch_date,
                "DAYS_SINCE_LAUNCH": days_since_launch,
                "SEASON": sales_info["season"],
                "IS_WEEKEND": sales_info["is_weekend"],
                "IS_HOLIDAY": sales_info["is_holiday"],
                "PROMOTION_ACTIVE": sales_info["promotion_active"]
            })
            
            current_date_ptr += timedelta(days=1)

    # Convert to DataFrame
    df = pd.DataFrame(sales_data)
    df = df.sort_values(by=['DAY'])

    # Clear existing data and write new data
    session.sql("TRUNCATE TABLE PRODUCT_SALES").collect()
    session.write_pandas(df, 'PRODUCT_SALES')

    return f"Data successfully generated and inserted into PRODUCT_SALES: {len(df)} records"
$$;

-- Stored procedure to generate product sales analysis
CREATE OR REPLACE PROCEDURE generate_product_sales_analysis()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy', 'scipy')
HANDLER = 'main'
AS
$$
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
try:
    from scipy import stats
except ImportError:
    stats = None

def main(session):
    # Read PRODUCT_SALES data
    df = session.table("PRODUCT_SALES").to_pandas()
    
    def generate_periodic_analysis(df):
        max_weeks = 30
        periodic_stats = []
        furniture_pieces = df['PRODUCT_NAME'].unique()
        
        for week_num in range(1, max_weeks + 1):
            start_day = (week_num - 1) * 7
            end_day = (week_num * 7) - 1
            
            period_sales = {}
            for furniture in furniture_pieces:
                furniture_data = df[(df['PRODUCT_NAME'] == furniture) & 
                              (df['DAYS_SINCE_LAUNCH'] >= start_day) & 
                              (df['DAYS_SINCE_LAUNCH'] <= end_day)]
                
                if len(furniture_data) == 7:  # Exactly 7 days
                    period_sales[furniture] = furniture_data['DAILY_SALES_UNITS_TOTAL'].sum()
            
            if len(period_sales) < 2:
                continue
                
            sales_values = list(period_sales.values())
            pct_25 = np.percentile(sales_values, 25)
            pct_50 = np.percentile(sales_values, 50)
            pct_75 = np.percentile(sales_values, 75)
            pct_90 = np.percentile(sales_values, 90)
            
            for furniture, total_sales in period_sales.items():
                furniture_data = df[(df['PRODUCT_NAME'] == furniture) & 
                              (df['DAYS_SINCE_LAUNCH'] >= start_day) & 
                              (df['DAYS_SINCE_LAUNCH'] <= end_day)]
                
                launch_date = df[df['PRODUCT_NAME'] == furniture]['LAUNCH_DATE'].iloc[0]
                period_start_date = launch_date + timedelta(days=start_day)
                period_end_date = launch_date + timedelta(days=end_day)
                
                # Calculate metrics
                avg_daily_sales_online = furniture_data['DAILY_SALES_UNITS_ONLINE'].mean()
                avg_daily_sales_northeast = furniture_data['DAILY_SALES_UNITS_NORTHEAST'].mean()
                avg_daily_sales_northwest = furniture_data['DAILY_SALES_UNITS_NORTHWEST'].mean()
                avg_daily_sales_southeast = furniture_data['DAILY_SALES_UNITS_SOUTHEAST'].mean()
                avg_daily_sales_southwest = furniture_data['DAILY_SALES_UNITS_SOUTHWEST'].mean()
                avg_daily_sales = furniture_data['DAILY_SALES_UNITS_TOTAL'].mean()

                total_sales_online = furniture_data['DAILY_SALES_UNITS_ONLINE'].sum()
                total_sales_northeast = furniture_data['DAILY_SALES_UNITS_NORTHEAST'].sum()
                total_sales_northwest = furniture_data['DAILY_SALES_UNITS_NORTHWEST'].sum()
                total_sales_southeast = furniture_data['DAILY_SALES_UNITS_SOUTHEAST'].sum()
                total_sales_southwest = furniture_data['DAILY_SALES_UNITS_SOUTHWEST'].sum()
                
                # Growth calculation
                if week_num == 1:
                    sales_growth = 0
                else:
                    prev_week_sales = None
                    for entry in periodic_stats:
                        if entry['PRODUCT_NAME'] == furniture and entry['WEEK_NUMBER'] == week_num - 1:
                            prev_week_sales = entry['TOTAL_SALES_UNITS']
                            break
                    
                    if prev_week_sales is not None and prev_week_sales > 0:
                        sales_growth = ((total_sales / prev_week_sales) - 1) * 100
                    else:
                        sales_growth = 0
                
                # Calculate cumulative sales
                cumulative_sales = total_sales
                for entry in periodic_stats:
                    if entry['PRODUCT_NAME'] == furniture and entry['WEEK_NUMBER'] < week_num:
                        cumulative_sales += entry['TOTAL_SALES_UNITS']
                
                # Calculate Z-score
                other_furniture = [f for f in furniture_pieces if f != furniture and f in period_sales]
                zscore = 0
                if other_furniture:
                    other_sales = [period_sales[f] for f in other_furniture]
                    mean_others = np.mean(other_sales)
                    std_others = np.std(other_sales)
                    zscore = (total_sales - mean_others) / std_others if std_others > 0 else 0
                    
                # Calculate percentile ranking
                percentile = sum(total_sales >= np.array(list(period_sales.values()))) / len(period_sales) * 100
                
                # t-test
                ttest_pvalue = 0.5  # Default value
                is_significant = False
                if stats and other_sales and len(other_sales) > 1:
                    try:
                        t_statistic, ttest_pvalue = stats.ttest_1samp(other_sales, total_sales)
                        is_significant = ttest_pvalue < 0.05
                    except:
                        pass
                
                # Calculate lift
                mean_sales = np.mean(list(period_sales.values()))
                lift = ((total_sales / mean_sales) - 1) * 100 if mean_sales > 0 else 0
                
                periodic_stats.append({
                    'PRODUCT_NAME': furniture,
                    'WEEK_NUMBER': week_num,
                    'PERIOD_START_DATE': period_start_date,
                    'PERIOD_END_DATE': period_end_date,
                    'TOTAL_SALES_UNITS_ONLINE': total_sales_online,
                    'TOTAL_SALES_UNITS_NORTHEAST': total_sales_northeast,
                    'TOTAL_SALES_UNITS_NORTHWEST': total_sales_northwest,
                    'TOTAL_SALES_UNITS_SOUTHEAST': total_sales_southeast,
                    'TOTAL_SALES_UNITS_SOUTHWEST': total_sales_southwest,
                    'TOTAL_SALES_UNITS': total_sales,
                    'AVG_DAILY_UNITS_ONLINE': avg_daily_sales_online,
                    'AVG_DAILY_UNITS_NORTHEAST': avg_daily_sales_northeast,
                    'AVG_DAILY_UNITS_NORTHWEST': avg_daily_sales_northwest,
                    'AVG_DAILY_UNITS_SOUTHEAST': avg_daily_sales_southeast,
                    'AVG_DAILY_UNITS_SOUTHWEST': avg_daily_sales_southwest,
                    'AVG_DAILY_UNITS_TOTAL': avg_daily_sales,
                    'SALES_GROWTH': sales_growth,
                    'CUMULATIVE_SALES_UNITS': cumulative_sales,
                    'ZSCORE': zscore,
                    'PERCENTILE': percentile,
                    'PCT_25': pct_25,
                    'PCT_50': pct_50,
                    'PCT_75': pct_75,
                    'PCT_90': pct_90,
                    'TTEST_PVALUE': ttest_pvalue,
                    'IS_SIGNIFICANT': is_significant,
                    'COMPARATIVE_LIFT': lift
                })
        
        return pd.DataFrame(periodic_stats)

    # Generate periodic analysis
    periodic_df = generate_periodic_analysis(df)
    periodic_df = periodic_df.sort_values(by=['PERIOD_END_DATE'])

    # Clear existing data and write new data
    session.sql("TRUNCATE TABLE PRODUCT_SALES_ANALYSIS").collect()
    session.write_pandas(periodic_df, 'PRODUCT_SALES_ANALYSIS')

    return f"Generated periodic analysis data: {len(periodic_df)} records"
$$;

-- =============================================================================
-- INITIAL DATA LOADING
-- =============================================================================

-- Insert sample product reviews
INSERT INTO product_reviews (product_id, product_name, product_description, review_title, review_text, rating, reviewer_name, review_date, verified_purchase, helpful_count, moderation_status, response_text, review_source) VALUES 
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Amazing quality!', 'Holds a lot of books and looks amazing.', 3, 'Danielle', '2024-05-20', TRUE, 4, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Guests love it', 'A bit heavy to assemble, but lovely overall.', 5, 'Judith', '2024-08-14', TRUE, 1, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Too heavy', 'Perfect for the living room or office.', 3, 'Jeffrey', '2025-02-21', FALSE, 0, 'approved', NULL, 'FurnitureReviews'),
(102, 'Velvet Accent Chair', 'Luxurious velvet upholstery with elegant wooden legs.', 'Guests love it', 'Packaging was secure and well-protected.', 3, 'Curtis', '2025-02-22', TRUE, 8, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Just right', 'Packaging was secure and well-protected.', 4, 'Patricia', '2024-06-13', TRUE, 4, 'approved', NULL, 'FurnitureReviews'),
(102, 'Velvet Accent Chair', 'Luxurious velvet upholstery with elegant wooden legs.', 'Love it', 'A bit difficult to assemble, but lovely overall.', 3, 'Brittany', '2024-05-23', TRUE, 3, 'approved', NULL, 'FurnitureReviews'),
(103, 'Rustic Dining Table', 'Solid wood dining table with rustic farmhouse design.', 'Love it', 'Not a fan of the finish, but the quality is good.', 4, 'Anthony', '2024-08-03', TRUE, 14, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Not what I expected', 'A bit heavy to move, but lovely overall.', 5, 'Jesse', '2024-12-30', TRUE, 11, 'approved', NULL, 'FurnitureReviews'),
(102, 'Velvet Accent Chair', 'Luxurious velvet upholstery with elegant wooden legs.', 'Too soft', 'This chair transforms the room without being overwhelming.', 5, 'Anthony', '2024-07-27', TRUE, 9, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Perfect for the space', 'A bit heavy to move, but lovely overall.', 4, 'Jennifer', '2025-02-07', TRUE, 14, 'approved', NULL, 'FurnitureReviews'),
(103, 'Rustic Dining Table', 'Solid wood dining table with rustic farmhouse design.', 'Just right', 'Bought as a housewarming gift, and they loved it.', 4, 'Amy', '2024-08-04', TRUE, 8, 'approved', NULL, 'FurnitureReviews'),
(101, 'Industrial Bookshelf', 'Sturdy metal and wood bookshelf with industrial design.', 'Will buy again', 'My whole family enjoys this piece.', 5, 'Shane', '2024-08-27', FALSE, 7, 'approved', NULL, 'FurnitureReviews'),
(102, 'Velvet Accent Chair', 'Luxurious velvet upholstery with elegant wooden legs.', 'Stylish and comfortable', 'Packaging was secure and well-protected.', 4, 'Lisa', '2024-05-13', FALSE, 7, 'approved', NULL, 'FurnitureReviews'),
(103, 'Rustic Dining Table', 'Solid wood dining table with rustic farmhouse design.', 'Amazing quality!', 'Perfect for the dining room or kitchen.', 3, 'Katherine', '2024-07-12', TRUE, 12, 'approved', NULL, 'FurnitureReviews'),
(103, 'Rustic Dining Table', 'Solid wood dining table with rustic farmhouse design.', 'Too big', 'Perfect for the dining room or kitchen.', 5, 'Helen', '2024-09-20', FALSE, 10, 'approved', NULL, 'FurnitureReviews'),
(102, 'Velvet Accent Chair', 'Luxurious velvet upholstery with elegant wooden legs.', 'Stylish and comfortable', 'Packaging was secure and well-protected.', 5, 'Joshua', '2024-08-02', TRUE, 4, 'approved', NULL, 'FurnitureReviews'),
(103, 'Rustic Dining Table', 'Solid wood dining table with rustic farmhouse design.', 'Just right', 'Perfect for the dining room or kitchen.', 5, 'Susan', '2024-09-18', FALSE, 8, 'approved', NULL, 'FurnitureReviews'),
(104, 'Scandinavian Coffee Table', 'Minimalist design with clean lines and natural wood finish.', 'Will buy again', 'Packaging was secure and well-protected.', 4, 'Curtis', '2024-10-05', TRUE, 4, 'approved', NULL, 'FurnitureReviews'),
(104, 'Scandinavian Coffee Table', 'Minimalist design with clean lines and natural wood finish.', 'Too low', 'This table fits the room without being overwhelming.', 3, 'Colin', '2025-04-05', TRUE, 5, 'approved', NULL, 'FurnitureReviews'),
(104, 'Scandinavian Coffee Table', 'Minimalist design with clean lines and natural wood finish.', 'Will buy again', 'A bit lower than expected, but lovely overall.', 4, 'Maurice', '2024-08-21', TRUE, 14, 'approved', NULL, 'FurnitureReviews');

-- Insert sample social media data
INSERT INTO instagram_page_stream SELECT
(PARSE_JSON($$
{
  "data": [
    {
      "id": "17895695668004550",
      "text": "Absolutely love the Velvet Accent Chair! Perfect for my reading nook 🛋️✨",
      "username": "home.design.kate",
      "timestamp": "2025-05-11T14:32:10+0000"
    },
    {
      "id": "17895695668004551",
      "text": "The Industrial Bookshelf was way too heavy for me 😕",
      "username": "small.space.living",
      "timestamp": "2025-05-11T15:01:45+0000"
    },
    {
      "id": "17895695668004552",
      "text": "Rustic Dining Table is amazing—my whole family loves dinner time now!",
      "username": "thefarmhousehome",
      "timestamp": "2025-05-11T15:15:33+0000"
    },
    {
      "id": "17895695668004553",
      "text": "Scandinavian Coffee Table didn't match my decor at all, kind of disappointed.",
      "username": "modern_minimalist",
      "timestamp": "2025-05-11T15:42:01+0000"
    },
    {
      "id": "17895695668004554",
      "text": "These furniture pieces are gorgeous 😍 Do you offer white glove delivery?",
      "username": "luxury.home.decor",
      "timestamp": "2025-05-11T16:08:25+0000"
    },
    {
      "id": "17895695668004555",
      "text": "We got the home office bundle and it's perfect! Great quality and beautiful design 🏠",
      "username": "workfromhome.setup",
      "timestamp": "2025-05-11T16:37:42+0000"
    }
  ],
  "paging": {
    "cursors": {
      "before": "QVFIUjZA...",
      "after": "QVFIUlZA..."
    }
  }
}
$$));

INSERT INTO facebook_page_stream SELECT
(PARSE_JSON($$
{
  "data": [
    {
      "id": "987654321_111",
      "from": {
        "name": "Tina Marshall",
        "id": "1357924680"
      },
      "message": "I bought the Rustic Dining Table and it's divine! Will you be restocking the matching chairs soon?",
      "created_time": "2025-05-11T13:20:15+0000"
    },
    {
      "id": "987654321_112",
      "from": {
        "name": "Jason Liu",
        "id": "2468013579"
      },
      "message": "Industrial Bookshelf assembly gave me a headache. Way too complicated for me.",
      "created_time": "2025-05-11T14:03:08+0000"
    },
    {
      "id": "987654321_113",
      "from": {
        "name": "Emily Rivera",
        "id": "8642097531"
      },
      "message": "Velvet Accent Chair is now a family favorite 😍",
      "created_time": "2025-05-11T15:11:42+0000"
    },
    {
      "id": "987654321_114",
      "from": {
        "name": "Derek O'Connor",
        "id": "0192837465"
      },
      "message": "Not a fan of Scandinavian Coffee Table. Too minimalist for my taste.",
      "created_time": "2025-05-11T16:02:55+0000"
    },
    {
      "id": "987654321_115",
      "from": {
        "name": "Sara Bennett",
        "id": "1123581321"
      },
      "message": "Do you offer seasonal furniture collections? These would make perfect room makeovers!",
      "created_time": "2025-05-11T17:27:19+0000"
    }
  ],
  "paging": {
    "cursors": {
      "before": "QVFIUlh3...",
      "after": "QVFIUm5n..."
    },
    "next": "https://graph.facebook.com/v19.0/987654321/comments?after=QVFIUm5n..."
  }
}
$$));

-- Populate consolidated feedback table
INSERT INTO consolidated_feedback
    (product_name, comment_title, comment_text, commenter, comment_date, comment_source)
SELECT lower(product_name),
       review_title as comment_title, 
       review_text as comment_text,
       reviewer_name as commenter,
       review_date as comment_date, 
       'ecommerce'
FROM product_reviews
UNION ALL
SELECT lower(trim(get(snowflake.cortex.extract_answer(message, 'What is the name of the specific furniture product referenced in the comment? May be capitalized in the comment eg Industrial Bookshelf or Velvet Accent Chair.'), 0):answer, '"')) as product_name,
       snowflake.cortex.complete('claude-3-5-sonnet', 'Write a short title, just the title and no other text, for this review: '||message) as comment_title,
       message as comment_text,
       from_name as commenter,
       post_time::date as comment_date, 
       'facebook'
FROM facebook_posts
UNION ALL
SELECT lower(trim(get(snowflake.cortex.extract_answer(message, 'What is the name of the specific furniture product referenced in the comment? May be capitalized in the comment eg Industrial Bookshelf or Velvet Accent Chair.'), 0):answer, '"')) as product_name,
       snowflake.cortex.complete('claude-3-5-sonnet', 'Write a short title, just the title and no other text, for this review: '||message) as comment_title,
       message as comment_text,
       from_name as commenter,
       post_time::date as comment_date, 
       'instagram'
FROM instagram_posts;

-- =============================================================================
-- GENERATE SAMPLE DATA USING STORED PROCEDURES
-- =============================================================================

-- Generate daily comment summary data
CALL generate_daily_comment_summary();

-- Generate product comment stats
CALL generate_product_comment_stats();

-- Generate product sales data
CALL generate_product_sales();

-- Generate product sales analysis
CALL generate_product_sales_analysis();

-- =============================================================================
-- POPULATE INVENTORY TABLE
-- =============================================================================

-- Generate initial inventory based on sales averages
INSERT INTO product_inventory (
    product_name,
    units_available_online,
    units_available_northeast,
    units_available_southeast,
    units_available_southwest,
    units_available_northwest,
    inventory_as_of_date
)
SELECT product_name, 
       avg(TOTAL_SALES_UNITS_ONLINE)*13 as units_available_online,
       avg(TOTAL_SALES_UNITS_northeast)*13 as units_available_northeast,
       avg(TOTAL_SALES_UNITS_southeast)*13 as units_available_southeast,
       avg(TOTAL_SALES_UNITS_southwest)*13 as units_available_southwest,
       avg(TOTAL_SALES_UNITS_northwest)*13 as units_available_northwest,
       '2025-06-23' as inventory_as_of_date
FROM PRODUCT_SALES_ANALYSIS
GROUP BY 1,7;

-- Adjust Velvet Accent Chair inventory for the story (simulate supply chain adjustments)
UPDATE product_inventory 
SET units_available_online = units_available_online - 2800, 
    units_available_northeast = units_available_northeast + 2500,
    units_available_southwest = units_available_southwest + 500,
    units_available_southeast = units_available_southeast + 2000
WHERE product_name = 'Velvet Accent Chair';

-- =============================================================================
-- SUMMARY QUERIES FOR VALIDATION
-- =============================================================================

-- Daily summary aggregation example
SELECT product_name, comment_date,
       AI_AGG(comment_title||' '||comment_text, 
              'Summarize what people are saying about this furniture product online.') as summary,
       sum(case when sentiment<0 then 1 else 0 end) as num_negative_reviews,
       sum(case when sentiment>0 then 1 else 0 end) as num_positive_reviews,
       sum(sentiment) as total_sentiment,
       avg(sentiment) as average_sentiment
FROM enriched_feedback
GROUP BY 1,2
ORDER BY 1,2;

-- =============================================================================
-- COMPLETION MESSAGE
-- =============================================================================

SELECT 'Furniture & Home setup completed successfully! All tables, views, dynamic tables, and sample data have been created.' as status;





-- load semantic models




-- create intelligence_agent from Snowsight
