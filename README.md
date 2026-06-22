# Decoding Customer Value: A SQL-Driven Retention Strategy 🛍️

![Certificate](Decoding_customer_value.png)

*Certified by IIT Guwahati Summer Analytics* | *Consulting & Analytics Club*

## 📌 Project Summary & Business Impact
This submission solves the "Cold Start" loyalty problem for a D2C Fashion brand. By utilizing Python as a deterministic feature-engineering engine, we synthesized latent Loyalty, Value, and Promo-Dependency metrics from raw, unlabelled transactional data. These dimensions were then queried via a structured SQL analytics layer to generate the final Executive Retention Playbook.

## ⚙️ Execution Instructions (Local Environment)
This pipeline is architected for local execution and deterministic data synthesis.

1. Download or clone this repository to your local machine.
2. Open `D2C_Feature_Engine.ipynb` using Jupyter, VS Code, or your preferred IDE. 
3. Execute the Python cells sequentially. The engine will read the raw `transactions.csv` file from the root directory and automatically generate the structured `clean_customer_dimensions.csv` file.
4. Open `Retention_Queries.sql` in any standard SQL environment (or text editor) to view the analytical logic and execute the 5 core business queries against the newly generated dimensional database.

## 📂 Repository Contents
* `D2C_Feature_Engine.ipynb`: **Python Pipeline** — Ingests raw data and synthesizes missing loyalty/churn labels.
* `Retention_Queries.sql`: **SQL Analytics** — The structured query layer answering the prompt's 5 core business questions.
* `HackerEarth Hackathon8fc332d.pdf`: **The Executive Report** — Details the Promo Sunset Plan and the Ideal Customer Profile (ICP).
* `transactions.csv`: Raw, unlabelled transactional data.
* `clean_customer_dimensions.csv`: The engineered dimensional database (output generated via Python).
