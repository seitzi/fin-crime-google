# Google Searches Indicate Financial Crime in Countries

This repository provides the code for the report [Google Searches Indicate Financial Crime in Countries](Google%20Searches%20Indicate%20Financial%20Crime%20in%20Countries.pdf).

## Abstract

A theory of amplification of public interest by financial crime in countries and the crucial role of internet
search in today’s information gathering process, as well as perceived online anonymity, suggest
the use of online interest measured by internet search volumes as indicator of financial crime in
countries. This report finds significant correlation between Google search volumes for _money laundering_
and _corruption_ in countries and corresponding indicators. Thus, Google search volumes are
proposed as complementary source for country risk assessments in financial crime prevention with
specified limitations.

![Diagram Money Laundering](figure%201%20ML.jpg)
![Diagram Corruption](figure%201%20corruption.jpg)

**Figure:** Comparison between Google search topic _Money Laundering / Corruption_ and mean of money laundering / corruption indicators. Each dot represents a country with a relative Google search volume (x-axis) and a mean of all available indicators (y-axis). The dot size relates to the number of available indicators. The green line shows a cubic smoothing spline fitted to the data and the red line a linear regression with 95 % confidence intervals and slope with p-value (null-hypothesis: no linear dependence) as indicated below the graph. Also printed below the graph are computed Pearson (r) and Kendall (tau) correlation coefficients with corresponding p-values (null-hypothesis: no positive correlation, one-sided test).

## Input data

### Google Trends

Google publishes search volume data via [Google Trends](https://www.google.com/trends). We chose a world-wide range and a time period from 01.01.2004 to 28.04.2019.

Google provides relative popularity of search volumes, i.e. the number of searches for _Money Laundering_ or related searches in a given country for a given time period is divided by the total number of searches in the country and time range. This allows to compare search volumes between countries (and time ranges) without introducing a bias for countries with larger internet populations than other countries.
We min-max scale the relative search volumes such that the values are between 0 (lowest relative search volumes) and 100 (highest relative search volumes).

Following search queries were used for (1) Money Laundering and (2) Corruption:
1. `"money laundering"+"blanchiment d’argent"+"غسيل الأموال"+"lavado de dinero"+"lavagem de dinheiro"`
2. `"corruption"+"فساد "+"corrupción"+"corrupção"`

The derivation of these search terms and further explanations can be found in the [report](Google%20Searches%20Indicate%20Financial%20Crime%20in%20Countries.pdf).

### Money Laundering Indicators

* [FATF high-risk and other monitored jurisdictions:](https://www.fatf-gafi.org/en/countries/black-and-grey-lists.html)
Financial Action Task Force (FATF) identifies and publishes jurisdictions with strategic anti-money laundering (AML) or counter-terrorism financing (CFT) deficiencies three times a year. The basis is a review by the International Co-operation Review Group (ICRG). This list included 13 countries as of April 2019.

* [2018 Basel AML Index:](https://index.baselgovernance.org/)
The International Centre for Asset Recovery, part of the Basel Institute on Governance, publishes annually the Basel Anti-Money Laundering Index which is an independent ranking assessing the risk of money laundering and terrorist financing. It is a composite index based on public sources and third-party assessments. The version of 2018 included 129 countries. We min-max scale the 2018 overall scores such that the values are between 0 (lowest risk of money laundering) and 100 (highest risk of money laundering).

* [Egmont Group Members:](https://en.wikipedia.org/wiki/Egmont_Group_of_Financial_Intelligence_Units)
The Egmont Group of Financial Intelligence Units (FIUs) is a 1995 founded network of 159 FIUs which are central, national agencies with the mission to collect and analyze information on financial activities suspected of being money laundering or terrorism financing and to inform public prosecution agencies if sufficient evidence is found. The Egmont Group has the purpose of providing a global forum for FIUs to improve cooperation and provides various support to its members. A country which has no FIU being Egmont Group member is viewed as non-cooperative and might not show sufficient efforts in combatting money laundering.

* [Offshore Financial Centres (FSF-IMF 2000, IMF 2007, IMF 2018):](https://en.wikipedia.org/wiki/Offshore_financial_centre)
A country is an Offshore Financial Centre (OFC) if the largest users of the financial sector are nonresidents. Financial Stability Forum (FSF) and International Monetary Fund (IMF) identified 48 countries as OFCs (grouped into 3 groups according to quality of supervision and cooperation in the country, rated here as 33, 66, and 100; countries not on the list as 0) based on a qualitative approach in 2000. Using a quantitative approach, IMF published a revised list of OFCs (without grouping) in 2007 (22 countries) and 2018 (8 countries). The classification as an OFC does not necessarily coincide with higher money laundering rates but successful OFCs facilitate tax evasion and money laundering.

* [Financial Secrecy Index:](https://www.financialsecrecyindex.com/introduction/fsi-2018-results)
Tax Justice Network ranks countries according to secrecy in the financial sector based on 20 indicators. Similarly to OFCs, financial secrecy does not directly imply higher money laundering rates but can serve as an indicator. We min-max scale the 2018 secrecy score such that the values are between 0 (least secrecy) and 100 (most secrecy).

* [EU list of non-cooperative tax jurisdictions:](https://ec.europa.eu/taxation_customs/tax-common-eu-list_en)
The member states of the European Union (EU) agreed on 05.12.18 on a list of non-cooperative tax jurisdictions and updated it subsequently. The list is based on screenings and dialogues with non-EU countries, to assess them against criteria for good governance such as tax transparency, fair taxation, the implementation of OECD BEPS measures and substance requirements for zero-tax countries. The version of 12.03.19 included 15 countries.

### Corruption Indicators

* [Corruption Perceptions Index:](https://www.transparency.org/cpi/2018)
Transparency International releases this annual rating of the relative degree of corruption every year since 1995 and describes it as _the leading global indicator of public sector corruption_. The version of 2018 was based on 13 surveys and expert assessments to measure public sector corruption in 180 countries and territories, giving each a score from zero (highly corrupt) to 100 (very clean). We min-max scale the negative 2018 scores such that the values are between 0 (lowest perception of corruption) and 100 (highest perception of corruption).

* [Control of Corruption:](http://info.worldbank.org/governance/wgi/#home)
Control of Corruption is one of six dimensions in World Bank’s Worldwide Governance Indicators (WGI) which is based on a large number of enterprise, citizen and expert surveys, in total over 30 data sources. The values (estimate) reflect a rating of governance which ranges from -2.5 (weak) to 2.5 (strong) governance performance). We min-max scale the negative country means of available data in years from 1996 up to 2017 such that the values are between 0 (strongest governance) and 100 (weakest governance).

* [Global Corruption Barometer:](https://www.transparency.org/en/news/global-corruption-barometer-citizens-voices-from-around-the-world)
Every few years, Transparency International (TI) conducts world* [wide public opinion surveys asking citizens about their direct personal experience of corruption. TI states that this is the largest public opinion survey on corruption. The version of 2017 covered 119 countries, territories and regions and was based on interviews with 162,136 adults from March 2014 until January 2017.
Question 3: _Total bribery rates by country (excluding no contact: percentage of survey participants who had contact with a government service in the past 12 months and had to pay a bribe, give a gift, or do a favor in order to receive the service)_ is assessed here as it reflects best experience of corruption.

* [World Bank Indicator IC.FRM.BRIB.ZS bribery incidence:](https://data.worldbank.org/indicator/IC.FRM.BRIB.ZS)
This bribery incidence is based on World Bank enterprise surveys and represents the percentage of firms experiencing at least one bribe payment request across 6 public transactions dealing with utilities access, permits, licenses, and taxes. 150 to 1800 (depending on size of economy) Business owners or top managers are surveyed every year. We min-max scale the country means of all available data in years from 2006 up to 2018 such that the values are between 0 (fewest bribery incidences) and 100 (most bribery incidences).

* [World Happiness Report - Perception of Corruption:](https://worldhappiness.report/ed/2019/)
The World Happiness Report is an annual survey about multiple topics of perceived happiness in 156 countries and is produced by the United Nations Sustainable Development Solutions Network. We consider Corruption Perception which is the national average of the survey responses to two yes/no questions in Gallup World Poll: _Is corruption widespread throughout the government or not?_ and _Is corruption widespread within businesses or not?_
We min-max scale the country means of all available data in years from 2005 up to 2018 such that the values are between 0 (lowest perception of corruption) and 100 (highest perception of corruption).

* [TRACE Bribery Risk Matrix® 2018:](https://www.traceinternational.org/trace-matrix)
TRACE published annually bribery risks of 200 countries which is a combination of the four domains Business Interactions with Government, Anti-bribery Deterrence and Enforcement, Government and Civil Service Transparency and Capacity for Civil Society Oversight. The total score ranges from 0 (lowest bribery risk) to 100 (highest bribery risk).






