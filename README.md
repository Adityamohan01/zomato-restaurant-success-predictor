# Zomato / Swiggy Restaurant Success Predictor

I built this project to answer a question that genuinely curious me — why do some restaurants on Zomato and Swiggy thrive while others shut down within months, even in the same city and cuisine category?

To find out, I analysed 500 restaurants across 8 Indian cities using Python, SQL, Google Sheets, and Tableau. Here's what I found.

---

## What I Actually Found

The most surprising insight wasn't what I expected. I went in assuming sentiment score would be the strongest predictor of success — turns out star rating dominates with a correlation of 0.744. Sentiment score sits at just 0.136. Lesson learned: don't assume, let the data speak.

A few other things that stood out:

- Restaurants delivering in under 30 minutes scored 51.8 on average vs 44.2 for slow ones. Speed matters more than most owners realise.
- Struggling restaurants offer the highest average discount at 22% — more than thriving ones. They're trying to buy customers with discounts but it clearly isn't working. Over-discounting is a symptom of failure, not a fix.
- Biryani leads all cuisines with an avg success score of 51.4. If you're opening a restaurant in India, the data says start with Biryani.
- Thriving restaurants average a 4.63 rating. Closed ones average 3.11. That gap of 1.5 stars is the difference between surviving and shutting down.

---

## The Dashboard

I built a 5-chart Tableau dashboard that lets you explore all of this visually — status breakdown by city, cuisine rankings, the rating vs success bubble chart, and delivery speed analysis.

[View the live dashboard here](https://public.tableau.com/views/ZomatoSwiggyRestaurantSuccessPredictor/ZomatoSuccessDashboard?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## Tools and What I Used Each For

**Python** — loaded and cleaned the data, built 10 EDA charts, ran correlation analysis, and trained a Random Forest classifier to predict restaurant status.

**SQL (MySQL)** — wrote 8 business queries covering survival rates by city, platform impact, the discount trap analysis, delivery speed segmentation, and cuisine performance ranking.

**Google Sheets** — built 4 pivot tables with conditional formatting and charts for quick business-level summaries.

**Tableau** — designed the final interactive dashboard with 5 visualisations including a bubble chart and a stacked bar breakdown across all 8 cities.

---

## Dataset

500 restaurants · 8 cities · 20 columns

Cities covered: Delhi, Mumbai, Bangalore, Hyderabad, Chennai, Pune, Kolkata, Ahmedabad

The dataset was generated to reflect realistic patterns in Indian food delivery markets — ratings, delivery times, monthly orders, sentiment scores, platform presence, and a composite success score.

---

## How to Run This

Clone the repo and install dependencies:

```bash
pip install pandas numpy matplotlib seaborn scikit-learn jupyter
```

Open the notebook:

```bash
jupyter notebook notebooks/01_EDA_Zomato.ipynb
```

For SQL analysis, import `data/cleaned/zomato_cleaned.csv` into MySQL and run the queries in `sql/analysis_queries.sql`.

---

## What I'd Do Next

If I had access to real Zomato/Swiggy API data, I'd add time-series tracking to see how ratings trend over a restaurant's lifetime, and build a proper churn prediction model with hyperparameter tuning. The current Random Forest gives a solid baseline but real longitudinal data would make it far more powerful.

---

## Connect

If you have feedback on the analysis or want to discuss the findings, feel free to reach out.
