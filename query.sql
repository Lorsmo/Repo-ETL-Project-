SELECT co_income.id, co_income.state, co_income.county, co_income.p_c_p_income, poverty.poverty_population
FROM poverty
JOIN co_income ON
poverty.state_abbr=co_income.state and poverty.name_county=co_income.county;

