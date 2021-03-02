
**OVERVIEW:** 
As the McGill MMA class of 2021 looks forward to graduating in a few months, much emphasis is currently being placed on job searching. As emerging Data Scientists, many of the students hope to work at tech-enabled companies. Of course, the most prestigious and notable of these companies are the FAANG (Facebook, Apple, Amazon, Netflix, Google) companies. Past statistics have shown that our generation changes jobs on average every 18 months. Due to the uncertainty brought about by the COVID-19 pandemic, researchers anticipate that the average tenure will increase, because job security is of the utmost importance nowadays. Therefore, as the MMA class embarks on their job searching journey, it is crucial to choose the right company to work for based on one’s own work life preferences, because it is likely that leaving a job will be more difficult in the coming years. 

**VALUE PROPOSITION:**
We are creating atool to help MMA students understand which company is better to target according to how current and former employees feel about certain aspects of work life at these companies. By examining  reviews  from  Glassdoor,  pre-and  post-COVID,  we  will  be  able  to  uncover  valuable insights  which  allude  to  the  health  of  the  company, and what employees enjoy/don’t enjoy about working there. The goals of our solution are as follows:
- Help MMAjob seekers identify which FAANG company fit their preference.
- Help FAANG companies identify which departments are unhappy.

**OBJECTIVE:**
The insights we will derive are:
- Top 5 key topics that employees use to rate their experience at a company (Rank each company based on their performance within these topics)
- Difference in sentiments of former employees vs current employees
- Difference in sentiments across FAANG companies pre-and post-COVID
- Difference in sentiments across departments within each FAANG company

Tools: Python (Jupyter Notebook/Google Collab), Tableau
Techniques:
- ***Data Acquisition:*** Scraping data from Glassdoor with a script that uses python, json and chromedriver
- ***Data Pre-Processing:*** Remove contractions, Tokenization, Remove punctuations, Remove Stopwards, POS Tagging (wordnet), Lemmatization
- ***Topic Modelling:*** Document Term Matrix, LDA Model, visualization using pyLDAvis
- ***Bi-Grams:*** CountVectorizer, Frequency
- ***Sentiment Analysis:*** Vader Sentiment Analyzer
- ***Visualization:*** wordcloud, Tableau
