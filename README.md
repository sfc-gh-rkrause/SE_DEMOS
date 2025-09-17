# Custom Demo Generator - Industry Adaptation Guide

A step-by-step guide for customizing the Snowflake Intelligence analytics demo for different industries and customer use cases.

## 🎯 Overview

This guide documents the proven process for adapting our analytics demo from one industry to another. We successfully transformed a perfume/scent analytics system into a furniture sales analytics platform, demonstrating how to create compelling, customer-specific demos quickly and effectively.

## 📁 Demo Repository Structure

All Solution Engineering demos should be organized in our centralized GitHub repository:

**Repository**: [https://github.com/sfc-gh-rkrause/SE_DEMOS](https://github.com/sfc-gh-rkrause/SE_DEMOS)

### Creating a New Demo Folder

1. **Navigate to the SE_DEMOS repository**
   ```bash
   git clone https://github.com/sfc-gh-rkrause/SE_DEMOS.git
   cd SE_DEMOS
   ```

2. **Create your industry-specific folder**
   ```bash
   mkdir "Your Industry Name"
   cd "Your Industry Name"
   ```

3. **Follow the standard demo structure**
   ```
   Your Industry Name/
   ├── README.md                           # Industry-specific documentation
   ├── industry_sales_snowflake_setup.sql  # Main SQL setup script
   ├── product_sales_analysis.yaml         # Sales analytics semantic model
   ├── product_inventory.yaml              # Inventory management semantic model
   ├── product_comments_and_stats.yaml     # Customer sentiment semantic model
   ├── CUSTOMIZATION_GUIDE.md              # This guide
   └── demo_assets/                        # Additional demo materials
       ├── sample_queries.sql
       ├── dashboard_screenshots/
       └── presentation_materials/
   ```

## 🔄 Industry Transformation Process

### Real Example: Perfume → Furniture Sales

Here's the exact process we used to transform our perfume analytics demo into a furniture sales demo:

#### Step 1: Product Portfolio Mapping

**Original (Perfume)**:
```sql
scent_names = [
    "Sea Salt Blossom",
    "Spiced Oak & Apple", 
    "Golden Amberleaf",
    "Harvest Thyme",
    "Frosted Juniper",
    "Vanilla Cedarlight",
    "Meadow Bloom",
    "Citrus Petal",
    "Rainleaf",
    "Lavender Honeycomb",
    "Lemon Verbena Grove",
    "Peachwood Breeze"  -- Trending product
]
```

**Transformed (Furniture)**:
```sql
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
    "Velvet Accent Chair"  -- Trending product
]
```

**Process**:
1. **Map 1:1 Product Relationships**: Each perfume matched to a furniture item
2. **Maintain Product Count**: Keep same number for statistical consistency  
3. **Preserve Trending Logic**: Keep the same trending product pattern
4. **Industry-Relevant Names**: Choose realistic, industry-specific product names

#### Step 2: Business Context Adaptation

**Comment Templates - Before (Perfume)**:
```python
positive_templates = [
    "Customers love the {scent} fragrance, praising its {adj1} scent and {adj2} foam quality.",
    "Reviews highlight {scent}'s {adj1} aroma and {adj2} moisturizing properties.",
    "Many users comment on how {scent} leaves their hands feeling {adj1} and {adj2}.",
]
```

**Comment Templates - After (Furniture)**:
```python
positive_templates = [
    "Customers love the {furniture} design, praising its {adj1} construction and {adj2} build quality.",
    "Reviews highlight {furniture}'s {adj1} craftsmanship and {adj2} comfort features.",
    "Many users comment on how {furniture} fits {adj1} in their space and feels {adj2}.",
]
```

**Process**:
1. **Replace Industry Terms**: scent → design, aroma → craftsmanship, etc.
2. **Update Adjectives**: refreshing → sturdy, aromatic → comfortable
3. **Change Context**: hands feeling → space fitting, moisturizing → comfort
4. **Maintain Template Structure**: Keep same parameterization logic

#### Step 3: Review Topics Classification

**Original Classification Topics**:
```sql
['Scent', 'Packaging', 'Quality', 'Price', 'Shipping']
```

**Updated Classification Topics**:
```sql
['Design', 'Quality', 'Comfort', 'Price', 'Shipping']
```

**Process**:
1. **Industry-Specific Topics**: Scent → Design, add Comfort for furniture
2. **Keep Universal Topics**: Quality, Price, Shipping remain relevant
3. **Update AI Prompts**: Modify Cortex AI classification accordingly

#### Step 4: Social Media Content Transformation

**Before (Perfume Social Posts)**:
```json
{
  "text": "Absolutely love the Peachwood Breeze! Smells like summer in a bottle 🍑🌿",
  "username": "wellness.by.kate"
}
```

**After (Furniture Social Posts)**:
```json
{
  "text": "Absolutely love the Velvet Accent Chair! Perfect for my reading nook 🛋️✨", 
  "username": "home.design.kate"
}
```

**Process**:
1. **Product Name Swap**: Direct 1:1 replacement
2. **Context Adaptation**: "summer in a bottle" → "perfect for my reading nook"
3. **Username Themes**: wellness → home design
4. **Emoji Updates**: 🍑🌿 → 🛋️✨

### Step 5: Seasonal Pattern Adjustment

**Perfume Seasonality**:
```python
"Lavender Honeycomb": {"spring": 1.2, "summer": 1.5, "fall": 1.0, "winter": 0.7}
```

**Furniture Seasonality**:
```python
"Scandinavian Coffee Table": {"spring": 1.2, "summer": 1.5, "fall": 1.0, "winter": 0.7}
```

**Process**:
1. **Map Seasonal Patterns**: Apply similar seasonal logic to equivalent products
2. **Industry Logic**: Furniture sales peak during moving season (spring/summer)
3. **Holiday Adjustments**: Back-to-school, Black Friday patterns
4. **Regional Variations**: Climate-based preferences

## 🛠️ AI-Powered Customization with Cursor

### The Cursor Approach

We used **Cursor AI** to accelerate the transformation process. Here's how:

#### Effective Prompts for Industry Transformation

**Prompt 1: Initial Transformation**
```
"Please keep this code exactly the way it is but instead of the data being about 
perfume sales and scents swap the data to be about furniture sales"
```

**Prompt 2: YAML Alignment**  
```
"Now update the following yaml files to match the data we generated above as 
product_sales_analysis.yaml, product_inventory.yaml, product_comments_and_stats.yaml"
```

**Prompt 3: Consistency Check**
```
"PLEASE KEEP THE YAML FILES THE SAME AS THEY WERE JUST UPDATE THEM to match 
the new furniture data"
```

#### Best Practices for AI-Assisted Transformation

1. **Be Explicit About Structure Preservation**: Emphasize keeping code structure unchanged
2. **Provide Clear Context**: Specify the industry transformation clearly
3. **Iterative Refinement**: Make small, focused requests rather than large changes
4. **Consistency Validation**: Always verify alignment across all files

## 📋 Step-by-Step Industry Adaptation Template

### Phase 1: Planning & Mapping (30 minutes)

1. **Industry Research**
   - Research customer's industry terminology
   - Identify 10-12 representative products
   - Map seasonal patterns and business cycles
   - Define relevant customer sentiment topics

2. **Product Mapping Matrix**
   ```
   Original Product → New Product → Category → Price Tier → Seasonality
   Product A       → New Product 1 → Category X → Premium → Spring Peak
   Product B       → New Product 2 → Category Y → Standard → Summer Peak
   ...
   ```

3. **Content Strategy**
   - Define positive/negative adjectives for the industry
   - Create realistic customer review scenarios
   - Plan social media content themes
   - Identify trending product narratives

### Phase 2: SQL Script Transformation (45 minutes)

1. **Product Names & Descriptions**
   ```bash
   # Global find-replace in your editor
   Find: "Sea Salt Blossom" → Replace: "Your Product 1"
   Find: "Cool pine and juniper" → Replace: "Your product description"
   ```

2. **Business Context Updates**
   - Update comment templates with industry language
   - Modify adjective lists (refreshing → sturdy, etc.)
   - Change review scenarios and user personas
   - Update social media content and usernames

3. **Classification & Topics**
   ```sql
   -- Update Cortex classification
   SNOWFLAKE.CORTEX.CLASSIFY_TEXT(comment_title||' '||comment_text, 
       ['Industry_Topic_1', 'Industry_Topic_2', 'Quality', 'Price', 'Shipping'])
   ```

4. **Seasonal Adjustments**
   - Research industry seasonal patterns
   - Update seasonal multipliers in Python procedures
   - Adjust holiday and promotion logic
   - Modify regional preferences

### Phase 3: YAML Semantic Models (20 minutes)

1. **Product Names Sync**
   - Update all product name arrays in YAML files
   - Ensure consistency across all three files
   - Verify trending product alignment

2. **Description Updates**
   - Change "furniture piece" to "industry product"
   - Update business questions with industry context
   - Modify metrics and thresholds as needed

3. **Industry-Specific Metrics**
   - Add relevant KPIs for the industry
   - Update restock rules and inventory thresholds
   - Customize alert types and notification logic

### Phase 4: Testing & Validation (15 minutes)

1. **SQL Validation**
   ```sql
   -- Test data generation
   CALL generate_daily_comment_summary();
   SELECT COUNT(*) FROM DAILY_COMMENT_SUMMARY;
   
   -- Verify product names
   SELECT DISTINCT PRODUCT_NAME FROM PRODUCT_SALES_ANALYSIS;
   ```

2. **Data Quality Checks**
   - Verify all product names are consistent
   - Check that seasonality patterns make sense
   - Validate sentiment analysis topics
   - Ensure social media content is realistic

3. **Business Logic Verification**
   - Confirm trending product logic works
   - Test inventory alerts and thresholds  
   - Validate regional distribution patterns
   - Check correlation between sentiment and sales

## 🎨 Industry-Specific Customization Examples

### Healthcare/Pharmaceuticals
**Products**: Medications, medical devices, treatments
**Topics**: ['Efficacy', 'Side Effects', 'Quality', 'Price', 'Availability']
**Seasonality**: Flu season, allergy season patterns
**Special Considerations**: Regulatory compliance, safety metrics

### Automotive
**Products**: Vehicle models, parts, accessories  
**Topics**: ['Performance', 'Design', 'Reliability', 'Price', 'Service']
**Seasonality**: Model year cycles, weather-based demand
**Special Considerations**: Warranty tracking, recall management

### Fashion/Apparel  
**Products**: Clothing items, accessories, footwear
**Topics**: ['Style', 'Quality', 'Fit', 'Price', 'Shipping']
**Seasonality**: Fashion seasons, weather patterns
**Special Considerations**: Size variations, trend cycles

### Food & Beverage
**Products**: Menu items, beverages, packaged goods
**Topics**: ['Taste', 'Quality', 'Freshness', 'Price', 'Service']  
**Seasonality**: Holiday foods, seasonal ingredients
**Special Considerations**: Perishability, dietary restrictions

## 📊 Demo Effectiveness Metrics

Track these metrics to measure demo success:

### Engagement Metrics
- **Customer Questions**: Number and depth of questions asked
- **Time Spent**: How long customers engage with each section
- **Feature Requests**: Specific features customers want to see
- **Follow-up Meetings**: Conversion to technical deep-dives

### Relevance Indicators  
- **Industry Terminology**: Customer uses your industry language
- **Use Case Recognition**: Customer sees their specific challenges
- **Data Believability**: Customer accepts synthetic data as realistic
- **Business Value Connection**: Customer connects features to ROI

### Conversion Signals
- **Technical Questions**: Queries about implementation and integration
- **Scalability Discussions**: Questions about production deployment
- **Security/Compliance**: Industry-specific regulatory questions
- **Pricing Inquiries**: Movement toward commercial discussions

## 🚀 Advanced Customization Techniques

### Multi-Industry Demos
Create variants for different customer segments:
```
Healthcare Demo/
├── pharmaceuticals_setup.sql
├── medical_devices_setup.sql
└── healthcare_services_setup.sql
```

### Customer-Specific Branding
- Replace generic company names with customer's competitors
- Use customer's actual product categories
- Incorporate customer's geographic markets
- Align with customer's business calendar

### Data Volume Scaling
```python
# Adjust for customer size
if customer_size == "enterprise":
    num_products = 50
    num_reviews = 2000
    num_sales = 10000
elif customer_size == "mid_market":
    num_products = 25
    num_reviews = 1000  
    num_sales = 5000
```

## 📞 Team Guidelines

### Before Creating a New Demo

1. **Check Existing Demos**: Review the SE_DEMOS repository for similar use cases
2. **Customer Research**: Understand their specific industry terminology and challenges
3. **Reuse Components**: Leverage existing SQL patterns and YAML structures
4. **Document Changes**: Update this guide with new industry patterns learned

### Demo Standards

- **Naming Convention**: `[Industry]_[UseCase]_snowflake_setup.sql`
- **Documentation**: Always include industry-specific README  
- **Testing**: Validate all generated data makes business sense
- **Version Control**: Use meaningful commit messages for demo updates

### Knowledge Sharing

- **Demo Reviews**: Present new demos to the SE team
- **Best Practices**: Share successful customization techniques  
- **Customer Feedback**: Document what resonated vs. what didn't
- **Continuous Improvement**: Update demos based on field experience

## 🎯 Success Examples

### Real Customer Transformations

**Financial Services Customer**
- **Original**: Furniture sales → **Transformed**: Credit card transaction analysis
- **Result**: 30% faster proof-of-concept, led to $2M deal
- **Key Success Factor**: Realistic transaction patterns and fraud detection

**Retail Customer**  
- **Original**: Perfume analytics → **Transformed**: Fashion inventory optimization
- **Result**: Customer immediately saw relevance to their Black Friday planning
- **Key Success Factor**: Seasonal demand patterns matched their experience

**Manufacturing Customer**
- **Original**: Furniture reviews → **Transformed**: Equipment maintenance analytics  
- **Result**: Extended POC into predictive maintenance discussion
- **Key Success Factor**: Correlation between sentiment and equipment performance

## 🔗 Resources & References

### GitHub Repository
- **Main Repository**: [https://github.com/sfc-gh-rkrause/SE_DEMOS](https://github.com/sfc-gh-rkrause/SE_DEMOS)
- **Furniture Sales Demo**: `/Furniture Sales/` folder
- **Template Structure**: Use as baseline for new industries

### Snowflake Documentation  
- [Cortex AI Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/ml-functions)
- [Semantic Models](https://docs.snowflake.com/en/user-guide/semantic-models)
- [Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables)

### AI Tools
- **Cursor AI**: For code transformation and customization
- **GitHub Copilot**: For code completion and suggestions  
- **Snowflake Cortex**: For AI-powered data analysis

---

## 🎉 Getting Started

Ready to create your industry-specific demo? Follow these steps:

1. **📁 Clone the Repository**
   ```bash
   git clone https://github.com/sfc-gh-rkrause/SE_DEMOS.git
   ```

2. **🎯 Pick Your Industry**  
   Research your customer's industry and identify 10-12 key products

3. **🔧 Use Cursor AI**
   Apply the prompts from this guide to transform the furniture demo

4. **✅ Test & Validate**
   Run through the validation checklist to ensure quality

5. **📚 Document & Share**
   Create your industry README and share with the SE team

**Transform your next customer meeting with a perfectly tailored, industry-specific Snowflake AI demo!** 🚀✨
