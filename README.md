# Facebook Ad Vaccine Uptake

Simulated field experiment to assess the effectiveness of different Facebook ad campaigns in increasing COVID-19 vaccine uptake



## How to Run the Pipeline

### First-Time Setup

```bash
git clone https://github.com/sonamtg/Facebook-Ad-Vaccine-Uptake.git
cd Facebook-Ad-Vaccine-Uptake
```

### Initialize the R environment to automatically install all dependencies

```bash
Rscript -e "renv::restore()"
```

### Run the Entire Pipeline
Execute the master script to run all steps sequentially:

```bash
Rscript 00_run.R
```

### Run Specific Steps
Edit `00_run.R` to toggle scripts on/off (set 1 = run, 0 = skip)

1. **00_run.R**
- To run all the scripts
- Input required and output produced by each script

### Overview of the logic and methodologies used

2. **01_baseline_simulation.R** 

#### Demographic Distributions

- Unique IDs (unique_id)
  - Sequential Unique IDs starting at 135780 ensure each participant has a distinct identifier
  
- Survey Dates (baseline_date)
  - Uniform distribution across May 1 2021 to May 15, 2021
  
- Age (age)
   - Gamma Distribution (shape=6, rate=0.15):
   - Right-skewed to reflect fewer older participants 
   - Mean is approximately 40 (6/0.15), which is close to the U.S avg age
   - Limits at 18-90 years old via pmax()/pmin()
   
- Gender (gender)
  - Age-stratified probabilities
  - Reflects declining non-binary identification with age
  
- Marriage (married)
  - Age-dependent binomial probabilities
  - Captures increasing marriage rates with age
  
#### COVID-Related Variables

- COVID Concern Level (covid_concern_num/label)

Reflects typical public health survey distributions

- Vaccine Trust (vaccine_trust)
  - Higher education individuals trust vaccine

- Vaccination Status (vaccinated)
  - People already vaccinated during the baseline survey depends on the base rate by age, education, vaccine trust
  - Capped at 15% max probability to make sure at least 85% observations are not vaccinated 

- Recent Exposure (recent_expos)
  - Fixed 18% probability
  - Independent of other factors

#### Facebook Usage

- Facebook Usage (fb_active)
  - Peak daily usage at 26-40 (37%)
  
3. **02_treatment_assign.R** 

- Randomized Controlled Trial (RCT) using complete randomization using the randomizr package
- Random assignment: 1/3 receive the first ad (reason), 1/3 the second ad (emotions), and 1/3 none (control group)

4. **03_endline_simulation.R**

- Follow-up Period (survey_gap)
  - 14-28 days using Poisson distribution
  - Add the follow-up period to obtain the endline survey date
  
- Endline Vaccination Status (vaccinated_endline)
  - Final Vaccination Status based on their baseline characteristics, random individual factors, and treatment effects

  - Treatment Effects:
    - Reason: +4% (HS or less), +8% (college+)
    - Emotions: +15% (HS or less), +5% (college+)  
    
  - Final vaccination status using the binomial distribution function based on their calculated probability
  
5. **04_merge_and_process.R**

- Merge all the datasets together and summarization for figures and tables

6. **05_gen_output.R**

- Produce figures and tables

- The `vaccination_uplift.png` plot shows that the Emotions campaign causally increased vaccination rates by 9.1 percentage points compared to the control group and the Reason campaign increased vaccinations by 7.3 percentage points compared to the control group after accounting for baseline (which includes random) characteristics.
