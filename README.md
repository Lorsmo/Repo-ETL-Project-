# Project ETL Report

## E: Extract
Two original data sources:</br>
(1) One formatted in a CSV file, poverty per county (file in Resources folder) from</br> https://www2.census.gov/programs-surveys/saipe/datasets/time-series/model-tables/</br>
(2) One extracted from API, income per capita by county (US Bureau of Economics Analysis).  Method request is in JSON format</br>https://apps.bea.gov/api/data/UserID=Your36CharacterKey&method=GetData&datasetname=Regional&TableName=CAINC1&LineCode=3&Year=2017&GeoFips=COUNTY&ResultFormat=json</br>

For both of them we did the following imports using a jupyter notebook:</br>

(1) Dependencies and setup for extracting the CSV file
```python
import pandas as pd
from sqlalchemy import create_engine
from config import pwd
import psycopg2
```
(2) Dependencies for extracting the database API</br>
All items in (1) above + the following
```python
import json
from config import api_key
```

### (1) Store CSV into DataFrame
```python
csv_file = "Resources/allpovu.csv"
data_df = pd.read_csv(csv_file)
data_df.head()
```

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>2</th>
      <th>State FIPS code</th>
      <th>County FIPS code</th>
      <th>Name</th>
      <th>State Postal Code</th>
      <th>Poverty Universe, All Ages</th>
      <th>Poverty Universe, Age 5-17 related</th>
      <th>Poverty Universe, Age 0-17</th>
      <th>Poverty Universe, Age 0-4</th>
      <th>Poverty Universe, All Ages</th>
      <th>Poverty Universe, Age 5-17 related</th>
      <th>...</th>
      <th>Poverty Universe, Age 0-17</th>
      <th>Poverty Universe, Age 0-4</th>
      <th>Poverty Universe, All Ages</th>
      <th>Poverty Universe, Age 5-17 related</th>
      <th>Poverty Universe, Age 0-17</th>
      <th>Poverty Universe, Age 0-4</th>
      <th>Poverty Universe, All Ages</th>
      <th>Poverty Universe, Age 5-17 related</th>
      <th>Poverty Universe, Age 0-17</th>
      <th>Poverty Universe, Age 0-4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Table:  Estimated Population in Poverty Univer...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>July 2017 ACS-Like Poverty Universe for 2017 E...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>July 2016 ACS-Like Poverty Universe for 2016 E...</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>July 2000 CPS-Like Poverty Universe for IY 199...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>July 1999 CPS-Like Poverty Universe for IY 199...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>State FIPS code</td>
      <td>County FIPS code</td>
      <td>Name</td>
      <td>State Postal Code</td>
      <td>Poverty Universe, All Ages</td>
      <td>Poverty Universe, Age 5-17 related</td>
      <td>Poverty Universe, Age 0-17</td>
      <td>Poverty Universe, Age 0-4</td>
      <td>Poverty Universe, All Ages</td>
      <td>Poverty Universe, Age 5-17 related</td>
      <td>...</td>
      <td>Poverty Universe, Age 0-17</td>
      <td>Poverty Universe, Age 0-4</td>
      <td>Poverty Universe, All Ages</td>
      <td>Poverty Universe, Age 5-17 related</td>
      <td>Poverty Universe, Age 0-17</td>
      <td>Poverty Universe, Age 0-4</td>
      <td>Poverty Universe, All Ages</td>
      <td>Poverty Universe, Age 5-17 related</td>
      <td>Poverty Universe, Age 0-17</td>
      <td>Poverty Universe, Age 0-4</td>
    </tr>
    <tr>
      <th>3</th>
      <td>0</td>
      <td>0</td>
      <td>United States</td>
      <td>US</td>
      <td>317,741,588</td>
      <td>52,669,201</td>
      <td>72,452,925</td>
      <td>19,457,844</td>
      <td>315,165,470</td>
      <td>52,644,648</td>
      <td>...</td>
      <td>71,741,141</td>
      <td>19,181,906</td>
      <td>276207757</td>
      <td>51642359</td>
      <td>71684956</td>
      <td>18968750</td>
      <td>271059449</td>
      <td>51060953</td>
      <td>71338364</td>
      <td>19382484</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>0</td>
      <td>Alabama</td>
      <td>AL</td>
      <td>4,752,519</td>
      <td>790,771</td>
      <td>1,079,561</td>
      <td>285,282</td>
      <td>4,741,355</td>
      <td>791,471</td>
      <td>...</td>
      <td>1,104,080</td>
      <td>296,196</td>
      <td>4368014</td>
      <td>804291</td>
      <td>1120718</td>
      <td>293558</td>
      <td>4348444</td>
      <td>789510</td>
      <td>1088427</td>
      <td>295264</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 84 columns</p>
</div>

### (2) Extract API into DataFrame
```python
url = "https://apps.bea.gov/api/data/?UserID=" + api_key + "&method=GetData&datasetname=Regional&TableName=CAINC1&LineCode=3&Year=2017&GeoFips=COUNTY&ResultFormat=json"
response = requests.get(query_url).json()
df = pd.DataFrame(response['BEAAPI']['Results']['Data'])
df
```
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Code</th>
      <th>GeoFips</th>
      <th>GeoName</th>
      <th>TimePeriod</th>
      <th>CL_UNIT</th>
      <th>UNIT_MULT</th>
      <th>DataValue</th>
      <th>NoteRef</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>CAINC1-3</td>
      <td>00000</td>
      <td>United States</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>51,640</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>1</td>
      <td>CAINC1-3</td>
      <td>01000</td>
      <td>Alabama</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>40,805</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>2</td>
      <td>CAINC1-3</td>
      <td>01001</td>
      <td>Autauga, AL</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>40,484</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>3</td>
      <td>CAINC1-3</td>
      <td>01003</td>
      <td>Baldwin, AL</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>44,079</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>4</td>
      <td>CAINC1-3</td>
      <td>01005</td>
      <td>Barbour, AL</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>33,453</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>3193</td>
      <td>CAINC1-3</td>
      <td>94000</td>
      <td>Plains</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>49,174</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>3194</td>
      <td>CAINC1-3</td>
      <td>95000</td>
      <td>Southeast</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>45,198</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>3195</td>
      <td>CAINC1-3</td>
      <td>96000</td>
      <td>Southwest</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>45,834</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>3196</td>
      <td>CAINC1-3</td>
      <td>97000</td>
      <td>Rocky Mountain</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>49,265</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>3197</td>
      <td>CAINC1-3</td>
      <td>98000</td>
      <td>Far West</td>
      <td>2017</td>
      <td>Dollars</td>
      <td>0</td>
      <td>57,748</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>3198 rows × 8 columns</p>
</div>




# T: Transform: 

### (1) Poverty data
* Delete first rows
```python
poverty_data_df = data_df[4:]
```
* Keep columns for values of the year 2017
```python
poverty_df = poverty_data_df[['State FIPS code', 'County FIPS code', 'Name','State Postal Code','Poverty Universe, All Ages']].copy()
```
* Delete rows representing a state and not a county
```python
poverty_df = poverty_df.loc[poverty_df['County FIPS code'] != '0']
```
* Create a function in order to delete the word 'county' for each row of column 'name'
```python
def remove_county(county):
    return county.split(" ")[0]
poverty_df['Name'] = poverty_df['Name'].apply(remove_county)
```
* Reset index and change column names

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>state_fips_code</th>
      <th>county_fips_code</th>
      <th>name_county</th>
      <th>state_abbr</th>
      <th>poverty_population</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>1</td>
      <td>Autauga</td>
      <td>AL</td>
      <td>55,021</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>3</td>
      <td>Baldwin</td>
      <td>AL</td>
      <td>209,922</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1</td>
      <td>5</td>
      <td>Barbour</td>
      <td>AL</td>
      <td>22,224</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1</td>
      <td>7</td>
      <td>Bibb</td>
      <td>AL</td>
      <td>20,434</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>9</td>
      <td>Blount</td>
      <td>AL</td>
      <td>57,452</td>
    </tr>
  </tbody>
</table>
</div>

* Delete the comma in the number of column 'poverty population'
```python
poverty_df['poverty_population'] = poverty_df['poverty_population'].astype(str).str.replace(',', '')
```
### (2) Income data
* Split the 'GeoName' column in order to get one column 'County' with only the county name inside and anoter one with the state 
```python
df = df.join(df["GeoName"].str.split(", ", 1, expand=True).rename(columns={0:'County', 1:'State Abbr'}))
df["County"] = df["County"].str.replace("County", "")
```
* Keep only the columns we are interested in
```python
co_income = df.loc[:, ["State Abbr", "County", "DataValue", "GeoFips"]]
```
* Rename the columns
```python
co_income.rename(columns={"DataValue": "p_c_p_income", "GeoFips": "id", "State Abbr": "state", "County": "county"}, inplace=True)
```
* Clean the data, delete empty cells and replace comma with space
```python
co_income = co_income[co_income["state"].astype(str) != "None"]
co_income.dropna(inplace=True)
co_income = co_income.loc[co_income['p_c_p_income']!='(NA)']
co_income['p_c_p_income'] = co_income['p_c_p_income'].astype(str).str.replace(',', '')
```
* Set index on id
```python
co_income.set_index("id", inplace=True)
co_income.head()
```
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>state</th>
      <th>county</th>
      <th>p_c_p_income</th>
    </tr>
    <tr>
      <th>id</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>01001</td>
      <td>AL</td>
      <td>Autauga</td>
      <td>40484</td>
    </tr>
    <tr>
      <td>01003</td>
      <td>AL</td>
      <td>Baldwin</td>
      <td>44079</td>
    </tr>
    <tr>
      <td>01005</td>
      <td>AL</td>
      <td>Barbour</td>
      <td>33453</td>
    </tr>
    <tr>
      <td>01007</td>
      <td>AL</td>
      <td>Bibb</td>
      <td>30022</td>
    </tr>
    <tr>
      <td>01009</td>
      <td>AL</td>
      <td>Blount</td>
      <td>33707</td>
    </tr>
  </tbody>
</table>
</div>


# L: Load

* Create tables in SQL (database) in order to receive the data from DataFrame
```ruby
-- DROP TABLE public.poverty;

CREATE TABLE public.poverty
(
    id integer NOT NULL DEFAULT nextval('poverty_id_seq'::regclass),
    state_fips_code integer NOT NULL,
    county_fips_code integer NOT NULL,
    name_county character varying(50) COLLATE pg_catalog."default" NOT NULL,
    state_abbr character varying(3) COLLATE pg_catalog."default" NOT NULL,
    poverty_population character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT poverty_pkey PRIMARY KEY (id)
);
```
```ruby
-- DROP TABLE public.co_income;

CREATE TABLE public.co_income
(
    id text COLLATE pg_catalog."default" NOT NULL,
    state text COLLATE pg_catalog."default",
    county text COLLATE pg_catalog."default",
    p_c_p_income integer,
    CONSTRAINT co_income_pkey PRIMARY KEY (id)
);
```

* Connect to local database

```python
connection_string = f"postgres:{pwd}@localhost:5432/ETL"
engine = create_engine(f'postgresql://{connection_string}')
```

* Check for tables
```python
engine.table_names()
```
    ['poverty', 'co_income']

* Use pandas to load csv and data API converted DataFrame into database

```python
poverty_df.to_sql(name='poverty', con=engine, if_exists='append', index=False)
co_income.to_sql(name='co_income', con=engine, if_exists='append', index=True)
```
* Confirm data has been added by querying the tables
```python
pd.read_sql_query('select * from poverty', con=engine).head()
pd.read_sql_query('select * from co_income', con=engine).head()
```
* Join both tables on county name and state name:</br>
  In PgAdmin:
```ruby
SELECT co_income.id, co_income.state, co_income.county, co_income.p_c_p_income, poverty.poverty_population
FROM poverty
JOIN co_income ON
poverty.state_abbr=co_income.state and poverty.name_county=co_income.county;
```
  In Pandas:
```python
sql_join = r"""SELECT co_income.id, co_income.state, co_income.county, co_income.p_c_p_income, poverty.poverty_population 
            FROM poverty
            JOIN co_income
            ON poverty.state_abbr=co_income.state
            AND poverty.name_county=co_income.county;"""

res = pd.read_sql(sql_join, con=engine)
res.head()
```

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>state</th>
      <th>county</th>
      <th>p_c_p_income</th>
      <th>poverty_population</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>01001</td>
      <td>AL</td>
      <td>Autauga</td>
      <td>40484</td>
      <td>55021</td>
    </tr>
    <tr>
      <th>1</th>
      <td>01003</td>
      <td>AL</td>
      <td>Baldwin</td>
      <td>44079</td>
      <td>209922</td>
    </tr>
    <tr>
      <th>2</th>
      <td>01005</td>
      <td>AL</td>
      <td>Barbour</td>
      <td>33453</td>
      <td>22224</td>
    </tr>
    <tr>
      <th>3</th>
      <td>01007</td>
      <td>AL</td>
      <td>Bibb</td>
      <td>30022</td>
      <td>20434</td>
    </tr>
    <tr>
      <th>4</th>
      <td>01009</td>
      <td>AL</td>
      <td>Blount</td>
      <td>33707</td>
      <td>57452</td>
    </tr>
  </tbody>
</table>
</div>


