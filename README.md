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


# Load: the final database, tables/collections, and why this was chosen.

### Connect to local database


```python
rds_connection_string = f"postgres:{pwd}@localhost:5432/poverty_db"

engine = create_engine(f'postgresql://{rds_connection_string}')

```

### Check for tables


```python
engine.table_names()
```




    ['poverty']



### Use pandas to load csv converted DataFrame into database


```python
poverty_df.to_sql(name='poverty', con=engine, if_exists='append', index=False)
```

### Confirm data has been added by querying the poverty table


```python
pd.read_sql_query('select * from poverty', con=engine).head()
```


