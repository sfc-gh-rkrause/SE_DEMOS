# Furniture Sales Analytics - Snowflake Intelligence System

A comprehensive furniture retail analytics solution built on Snowflake with AI-powered sentiment analysis, sales forecasting, and inventory optimization.

## 🛋️ Overview

This system generates synthetic furniture sales data with realistic customer reviews, regional sales patterns, and inventory management for 12 furniture products. It includes advanced analytics, sentiment analysis, and statistical comparisons powered by Snowflake Cortex AI.

## 📁 Project Files

### Core Files
- **`furniture_sales_snowflake_setup.sql`** - Complete Snowflake database setup with tables, views, and stored procedures
- **`product_sales_analysis.yaml`** - Semantic model for sales performance analytics
- **`product_inventory.yaml`** - Semantic model for inventory management
- **`product_comments_and_stats.yaml`** - Semantic model for customer sentiment analysis

## 🛋️ Furniture Product Catalog

The system tracks 12 furniture products with realistic sales and review patterns:

| Product Name | Category | Launch Pattern | Special Notes |
|--------------|----------|---------------|---------------|
| Executive Oak Desk | Office | Established (2023) | Premium segment |
| Modern Sectional Sofa | Seating | Established (2023) | High volume |
| Rustic Dining Table | Dining | Established (2023) | Family-focused |
| Ergonomic Office Chair | Office | Established (2024) | Work-from-home trend |
| Industrial Bookshelf | Storage | Established (2024) | Seasonal patterns |
| Scandinavian Coffee Table | Tables | Established (2024) | Minimalist design |
| Memory Foam Mattress | Bedroom | Mid-cycle (2024) | Health & comfort focus |
| Vintage Leather Armchair | Seating | Mid-cycle (2024) | Premium vintage |
| Glass Top End Table | Tables | Mid-cycle (2024) | Modern style |
| Upholstered Storage Bench | Storage | Mid-cycle (2024) | Multi-functional |
| **Adjustable Standing Desk** | Office | **Recent (2025)** | **Trending up (+8.7%)** |
| **Velvet Accent Chair** | Seating | **Recent (2025)** | **Top trending (+15.3%)** |

## 🗄️ Database Schema

### Core Tables

#### `PRODUCT_SALES_ANALYSIS`
Weekly sales performance with statistical analysis
```sql
- PRODUCT_NAME: Furniture product identifier  
- WEEK_NUMBER: Week since launch (1, 2, 3...)
- TOTAL_SALES_UNITS: Combined sales across all channels
- SALES_GROWTH: Week-over-week growth percentage
- PERCENTILE: Performance ranking vs other products
- ZSCORE: Statistical significance measurement
- IS_SIGNIFICANT: Boolean for statistical significance
```

#### `PRODUCT_INVENTORY`
Real-time inventory across regions
```sql
- PRODUCT_NAME: Furniture product identifier
- UNITS_AVAILABLE_ONLINE: E-commerce inventory
- UNITS_AVAILABLE_NORTHEAST: Regional warehouse stock
- UNITS_AVAILABLE_NORTHWEST: Regional warehouse stock  
- UNITS_AVAILABLE_SOUTHEAST: Regional warehouse stock
- UNITS_AVAILABLE_SOUTHWEST: Regional warehouse stock
- INVENTORY_AS_OF_DATE: Snapshot date
```

#### `PRODUCT_COMMENT_STATS`
Weekly customer sentiment analysis
```sql
- PRODUCT_NAME: Furniture product identifier
- WEEK_NUMBER: Week since launch
- TOTAL_REVIEWS: Review volume
- POSITIVE_REVIEW_RATIO: % positive sentiment
- AVG_SENTIMENT: Average sentiment score (-1 to 1)
- SENTIMENT_PERCENTILE: Ranking vs other products
```

#### `DAILY_COMMENT_SUMMARY`
AI-generated daily review summaries
```sql
- PRODUCT_NAME: Furniture product identifier
- DAY: Summary date
- SUMMARY: AI-generated insights from Snowflake Cortex
- NUM_POSITIVE_REVIEWS: Daily positive review count
- NUM_NEGATIVE_REVIEWS: Daily negative review count
- AVERAGE_SENTIMENT: Daily sentiment average
```

### Dynamic Tables
- **`facebook_posts`** - Social media mentions processing
- **`instagram_posts`** - Social media engagement tracking

### Views
- **`enriched_feedback`** - Sentiment analysis with Snowflake Cortex
- **`weekly_category_comparison`** - Cross-category performance analysis

## 🚀 Quick Start

### Prerequisites
- Snowflake account with `ACCOUNTADMIN` privileges
- Access to Snowflake Cortex AI functions
- Compute warehouse (default: `COMPUTE_WH`)

### Installation Steps

1. **Execute the SQL Setup**
   ```sql
   -- Run the complete setup script
   @furniture_sales_snowflake_setup.sql
   ```

2. **Verify Installation**
   ```sql
   -- Check data generation
   SELECT COUNT(*) FROM PRODUCT_SALES_ANALYSIS;
   SELECT COUNT(*) FROM PRODUCT_INVENTORY; 
   SELECT COUNT(*) FROM DAILY_COMMENT_SUMMARY;
   ```

3. **Generate Sample Data**
   ```sql
   -- The setup script automatically calls these procedures
   CALL generate_daily_comment_summary();
   CALL generate_product_sales();
   CALL generate_product_sales_analysis();
   ```

## 📊 Key Features

### 🧠 AI-Powered Analytics
- **Sentiment Analysis**: Snowflake Cortex analyzes customer reviews
- **Topic Classification**: Automatically categorizes feedback (Design, Quality, Comfort, Price, Shipping)
- **Trend Detection**: Identifies improving/declining products
- **Statistical Significance**: P-values and Z-scores for performance comparisons

### 📈 Sales Intelligence
- **Weekly Performance Tracking**: Growth rates and trend analysis
- **Regional Sales Patterns**: 4 geographic regions + online
- **Seasonal Adjustments**: Different patterns by furniture category
- **Launch Cohort Analysis**: How new products compare to established ones

### 📦 Inventory Optimization
- **Multi-Region Tracking**: Online + 4 regional warehouses
- **Smart Thresholds**: Critical low (1,000), optimal (5,000-15,000), overstock (20,000+)
- **Restock Rules**: Different strategies for high-volume, premium, and seasonal items
- **Supply Chain Alerts**: Automated notifications for low stock

### 🎯 Business Intelligence
- **Cross-Product Analysis**: Performance comparisons and rankings
- **Customer Satisfaction Index**: Composite sentiment scoring
- **Market Basket Analysis**: Simulated customer purchasing patterns
- **Predictive Insights**: Statistical modeling for future performance

## 💼 Business Use Cases

### For Sales Teams
- **Product Performance**: Which furniture items drive most revenue?
- **Regional Optimization**: Where should we focus sales efforts?
- **Launch Success**: How are new products performing vs established ones?
- **Competitive Analysis**: Statistical significance of performance differences

### For Marketing Teams  
- **Customer Sentiment**: What do customers love/hate about each product?
- **Content Strategy**: Which features to highlight in campaigns?
- **Social Media**: Track mentions and engagement across platforms
- **Product Positioning**: Data-driven messaging for different furniture categories

### For Operations Teams
- **Inventory Planning**: Prevent stockouts while minimizing overstock
- **Regional Distribution**: Optimize warehouse allocation
- **Supply Chain**: Lead times and reorder points by product type
- **Quality Issues**: Early warning system from sentiment analysis

### For Executives
- **Business Health**: Overall furniture category performance
- **Growth Opportunities**: Trending products and market gaps  
- **Resource Allocation**: Which products deserve more investment?
- **Strategic Decisions**: Data-driven product line planning

## 📋 YAML Semantic Models

### `product_sales_analysis.yaml`
**Purpose**: Sales performance analytics and growth tracking
- Weekly sales units and growth rates
- Statistical comparisons between products  
- Percentile rankings and significance testing
- Business questions focused on sales optimization

### `product_inventory.yaml`  
**Purpose**: Inventory management and optimization
- Real-time stock levels across all regions
- Restock rules for different product categories
- Threshold management (critical, low, optimal, overstock)
- Business questions focused on supply chain efficiency

### `product_comments_and_stats.yaml`
**Purpose**: Customer sentiment and satisfaction tracking  
- Weekly review statistics and sentiment analysis
- Topic classification (Design, Quality, Comfort, Price, Shipping)
- Trending analysis for improving/declining products
- Business questions focused on customer experience

## 🔄 Data Refresh Schedule

### Automated Procedures
- **Daily**: `generate_daily_comment_summary()` - Fresh sentiment analysis
- **Weekly**: `generate_product_comment_stats()` - Weekly review aggregations  
- **Weekly**: `generate_product_sales()` - Sales data generation
- **Weekly**: `generate_product_sales_analysis()` - Performance analysis

### Manual Triggers
```sql
-- Refresh all data
CALL generate_daily_comment_summary();
CALL generate_product_comment_stats();  
CALL generate_product_sales();
CALL generate_product_sales_analysis();
```

## 🎭 Sample Queries

### Top Performing Furniture by Region
```sql
SELECT 
    PRODUCT_NAME,
    TOTAL_SALES_UNITS_NORTHEAST,
    TOTAL_SALES_UNITS_NORTHWEST,
    TOTAL_SALES_UNITS_SOUTHEAST,
    TOTAL_SALES_UNITS_SOUTHWEST,
    PERCENTILE
FROM PRODUCT_SALES_ANALYSIS 
WHERE WEEK_NUMBER = (SELECT MAX(WEEK_NUMBER) FROM PRODUCT_SALES_ANALYSIS)
ORDER BY PERCENTILE DESC;
```

### Customer Sentiment Leaders
```sql
SELECT 
    PRODUCT_NAME,
    AVG_SENTIMENT,
    POSITIVE_REVIEW_RATIO,
    TOTAL_REVIEWS,
    SENTIMENT_PERCENTILE
FROM PRODUCT_COMMENT_STATS
WHERE WEEK_NUMBER >= (SELECT MAX(WEEK_NUMBER) - 4 FROM PRODUCT_COMMENT_STATS)
GROUP BY 1,2,3,4,5
ORDER BY AVG_SENTIMENT DESC;
```

### Inventory Alerts
```sql
SELECT 
    PRODUCT_NAME,
    (UNITS_AVAILABLE_ONLINE + UNITS_AVAILABLE_NORTHEAST + 
     UNITS_AVAILABLE_NORTHWEST + UNITS_AVAILABLE_SOUTHEAST + 
     UNITS_AVAILABLE_SOUTHWEST) as TOTAL_INVENTORY,
    CASE 
        WHEN TOTAL_INVENTORY < 1000 THEN 'CRITICAL'
        WHEN TOTAL_INVENTORY < 2500 THEN 'LOW'  
        WHEN TOTAL_INVENTORY > 20000 THEN 'OVERSTOCK'
        ELSE 'NORMAL'
    END as INVENTORY_STATUS
FROM PRODUCT_INVENTORY
WHERE INVENTORY_STATUS IN ('CRITICAL', 'LOW', 'OVERSTOCK')
ORDER BY TOTAL_INVENTORY;
```

### Trending Products Analysis
```sql
SELECT 
    p.PRODUCT_NAME,
    p.SALES_GROWTH as LATEST_GROWTH,
    c.AVG_SENTIMENT,
    c.SENTIMENT_PERCENTILE,
    CASE 
        WHEN p.PRODUCT_NAME = 'Velvet Accent Chair' THEN 'TOP TRENDING'
        WHEN p.PRODUCT_NAME = 'Adjustable Standing Desk' THEN 'TRENDING UP'
        ELSE 'STABLE'
    END as TREND_STATUS
FROM PRODUCT_SALES_ANALYSIS p
JOIN PRODUCT_COMMENT_STATS c ON p.PRODUCT_NAME = c.PRODUCT_NAME 
WHERE p.WEEK_NUMBER = (SELECT MAX(WEEK_NUMBER) FROM PRODUCT_SALES_ANALYSIS)
  AND c.WEEK_NUMBER = (SELECT MAX(WEEK_NUMBER) FROM PRODUCT_COMMENT_STATS)
ORDER BY p.SALES_GROWTH DESC;
```

## 🔧 Customization

### Adding New Products
1. Update the `furniture_names` array in stored procedures
2. Add seasonality patterns in `seasonality` dictionary  
3. Set product characteristics in `furniture_characteristics`
4. Update YAML files with new product names

### Modifying Regions
1. Update table schemas to add/remove regional columns
2. Modify stored procedures for new regional logic
3. Adjust inventory thresholds and restock rules
4. Update YAML semantic models

### Changing AI Analysis
1. Modify topic classification in `enriched_feedback` view
2. Update sentiment templates in stored procedures  
3. Adjust business rules for trending analysis
4. Customize alert thresholds

## 🆘 Troubleshooting

### Common Issues

**Data Not Generating**
```sql
-- Check if procedures exist
SHOW PROCEDURES LIKE 'generate%';

-- Verify table creation
SHOW TABLES;

-- Check for errors in recent runs
SELECT * FROM INFORMATION_SCHEMA.TASK_HISTORY 
WHERE NAME LIKE 'generate%' 
ORDER BY SCHEDULED_TIME DESC LIMIT 5;
```

**Empty Results**
```sql
-- Verify data exists
SELECT COUNT(*) FROM DAILY_COMMENT_SUMMARY;
SELECT MIN(DAY), MAX(DAY) FROM DAILY_COMMENT_SUMMARY;

-- Check date ranges
SELECT DISTINCT INVENTORY_AS_OF_DATE FROM PRODUCT_INVENTORY;
```

**Cortex AI Issues**
```sql
-- Verify Cortex access
SELECT SNOWFLAKE.CORTEX.SENTIMENT('This furniture is amazing!');

-- Check role permissions  
SHOW GRANTS TO ROLE retail_snowflake_intelligence_role;
```

## 📞 Support

### Getting Help
- **Documentation**: Snowflake Cortex AI documentation
- **Community**: Snowflake community forums
- **Professional**: Snowflake professional services

### Performance Optimization
- Use appropriate warehouse sizes for data generation
- Consider clustering keys for large tables
- Monitor query performance and optimize as needed
- Set up automated scaling for production workloads

---

## 🎉 Success Metrics

After successful setup, you should see:
- ✅ 12 furniture products with realistic sales patterns
- ✅ Thousands of generated sales records with regional distribution  
- ✅ AI-powered sentiment analysis of customer reviews
- ✅ Weekly performance statistics and trend analysis
- ✅ Inventory tracking across multiple regions
- ✅ Actionable business insights for furniture retail optimization

**Transform your furniture retail business with data-driven intelligence powered by Snowflake AI!** 🚀🛋️
