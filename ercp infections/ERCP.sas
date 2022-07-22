*Pull all ERCP procedures based on hcpcs (Carrier line, inpatient revenue);
*include C code pass through for Boston disposable duodenoscope:
https://www.bostonscientific.com/en-US/medical-specialties/gastroenterology/exalt.html?gclid=EAIaIQobChMIq9_Nj8Pn6wIVCvezCh17mwEZEAAYASAAEgLjdfD_BwE
;
*link claim and line so can identify diagnoses on same claim;
%macro ercp (out=, in1=, in2=);
proc sql;
	create table temp as
	select*
	from &in1    
	where hcpcs_cd in (
/*ERCP*/
'43260','43261','43262','43263','43264','43265','43273','43274','43275','43276','43277','43278',
'C1748'
						);
quit;
proc sql;
	create table &out as
	select *
	from temp a,
	&in2 b 
	where a.bene_id = b.bene_id and a.clm_id = b.clm_id;
quit;
%mend;
%ercp (out=ercp_carrier_15_01, in1=rif2015.bcarrier_line_01, in2=rif2015.bcarrier_claims_01);
%ercp (out=ercp_carrier_15_02, in1=rif2015.bcarrier_line_02, in2=rif2015.bcarrier_claims_02);
%ercp (out=ercp_carrier_15_03, in1=rif2015.bcarrier_line_03, in2=rif2015.bcarrier_claims_03);
%ercp (out=ercp_carrier_15_04, in1=rif2015.bcarrier_line_04, in2=rif2015.bcarrier_claims_04);
%ercp (out=ercp_carrier_15_05, in1=rif2015.bcarrier_line_05, in2=rif2015.bcarrier_claims_05);
%ercp (out=ercp_carrier_15_06, in1=rif2015.bcarrier_line_06, in2=rif2015.bcarrier_claims_06);
%ercp (out=ercp_carrier_15_07, in1=rif2015.bcarrier_line_07, in2=rif2015.bcarrier_claims_07);
%ercp (out=ercp_carrier_15_08, in1=rif2015.bcarrier_line_08, in2=rif2015.bcarrier_claims_08);
%ercp (out=ercp_carrier_15_09, in1=rif2015.bcarrier_line_09, in2=rif2015.bcarrier_claims_09);
%ercp (out=ercp_carrier_15_10, in1=rif2015.bcarrier_line_10, in2=rif2015.bcarrier_claims_10);
%ercp (out=ercp_carrier_15_11, in1=rif2015.bcarrier_line_11, in2=rif2015.bcarrier_claims_11);
%ercp (out=ercp_carrier_15_12, in1=rif2015.bcarrier_line_12, in2=rif2015.bcarrier_claims_12);

%ercp (out=ercp_carrier_16_01, in1=rif2016.bcarrier_line_01, in2=rif2016.bcarrier_claims_01);
%ercp (out=ercp_carrier_16_02, in1=rif2016.bcarrier_line_02, in2=rif2016.bcarrier_claims_02);
%ercp (out=ercp_carrier_16_03, in1=rif2016.bcarrier_line_03, in2=rif2016.bcarrier_claims_03);
%ercp (out=ercp_carrier_16_04, in1=rif2016.bcarrier_line_04, in2=rif2016.bcarrier_claims_04);
%ercp (out=ercp_carrier_16_05, in1=rif2016.bcarrier_line_05, in2=rif2016.bcarrier_claims_05);
%ercp (out=ercp_carrier_16_06, in1=rif2016.bcarrier_line_06, in2=rif2016.bcarrier_claims_06);
%ercp (out=ercp_carrier_16_07, in1=rif2016.bcarrier_line_07, in2=rif2016.bcarrier_claims_07);
%ercp (out=ercp_carrier_16_08, in1=rif2016.bcarrier_line_08, in2=rif2016.bcarrier_claims_08);
%ercp (out=ercp_carrier_16_09, in1=rif2016.bcarrier_line_09, in2=rif2016.bcarrier_claims_09);
%ercp (out=ercp_carrier_16_10, in1=rif2016.bcarrier_line_10, in2=rif2016.bcarrier_claims_10);
%ercp (out=ercp_carrier_16_11, in1=rif2016.bcarrier_line_11, in2=rif2016.bcarrier_claims_11);
%ercp (out=ercp_carrier_16_12, in1=rif2016.bcarrier_line_12, in2=rif2016.bcarrier_claims_12);

%ercp (out=ercp_carrier_17_01, in1=rif2017.bcarrier_line_01, in2=rif2017.bcarrier_claims_01);
%ercp (out=ercp_carrier_17_02, in1=rif2017.bcarrier_line_02, in2=rif2017.bcarrier_claims_02);
%ercp (out=ercp_carrier_17_03, in1=rif2017.bcarrier_line_03, in2=rif2017.bcarrier_claims_03);
%ercp (out=ercp_carrier_17_04, in1=rif2017.bcarrier_line_04, in2=rif2017.bcarrier_claims_04);
%ercp (out=ercp_carrier_17_05, in1=rif2017.bcarrier_line_05, in2=rif2017.bcarrier_claims_05);
%ercp (out=ercp_carrier_17_06, in1=rif2017.bcarrier_line_06, in2=rif2017.bcarrier_claims_06);
%ercp (out=ercp_carrier_17_07, in1=rif2017.bcarrier_line_07, in2=rif2017.bcarrier_claims_07);
%ercp (out=ercp_carrier_17_08, in1=rif2017.bcarrier_line_08, in2=rif2017.bcarrier_claims_08);
%ercp (out=ercp_carrier_17_09, in1=rif2017.bcarrier_line_09, in2=rif2017.bcarrier_claims_09);
%ercp (out=ercp_carrier_17_10, in1=rif2017.bcarrier_line_10, in2=rif2017.bcarrier_claims_10);
%ercp (out=ercp_carrier_17_11, in1=rif2017.bcarrier_line_11, in2=rif2017.bcarrier_claims_11);
%ercp (out=ercp_carrier_17_12, in1=rif2017.bcarrier_line_12, in2=rif2017.bcarrier_claims_12);

%ercp (out=ercp_carrier_18_01, in1=rifq2018.bcarrier_line_01, in2=rifq2018.bcarrier_claims_01);
%ercp (out=ercp_carrier_18_02, in1=rifq2018.bcarrier_line_02, in2=rifq2018.bcarrier_claims_02);
%ercp (out=ercp_carrier_18_03, in1=rifq2018.bcarrier_line_03, in2=rifq2018.bcarrier_claims_03);
%ercp (out=ercp_carrier_18_04, in1=rifq2018.bcarrier_line_04, in2=rifq2018.bcarrier_claims_04);
%ercp (out=ercp_carrier_18_05, in1=rifq2018.bcarrier_line_05, in2=rifq2018.bcarrier_claims_05);
%ercp (out=ercp_carrier_18_06, in1=rifq2018.bcarrier_line_06, in2=rifq2018.bcarrier_claims_06);
%ercp (out=ercp_carrier_18_07, in1=rifq2018.bcarrier_line_07, in2=rifq2018.bcarrier_claims_07);
%ercp (out=ercp_carrier_18_08, in1=rifq2018.bcarrier_line_08, in2=rifq2018.bcarrier_claims_08);
%ercp (out=ercp_carrier_18_09, in1=rifq2018.bcarrier_line_09, in2=rifq2018.bcarrier_claims_09);
%ercp (out=ercp_carrier_18_10, in1=rifq2018.bcarrier_line_10, in2=rifq2018.bcarrier_claims_10);
%ercp (out=ercp_carrier_18_11, in1=rifq2018.bcarrier_line_11, in2=rifq2018.bcarrier_claims_11);
%ercp (out=ercp_carrier_18_12, in1=rifq2018.bcarrier_line_12, in2=rifq2018.bcarrier_claims_12);

%ercp (out=ercp_carrier_19_01, in1=rifq2019.bcarrier_line_01, in2=rifq2019.bcarrier_claims_01);
%ercp (out=ercp_carrier_19_02, in1=rifq2019.bcarrier_line_02, in2=rifq2019.bcarrier_claims_02);
%ercp (out=ercp_carrier_19_03, in1=rifq2019.bcarrier_line_03, in2=rifq2019.bcarrier_claims_03);
%ercp (out=ercp_carrier_19_04, in1=rifq2019.bcarrier_line_04, in2=rifq2019.bcarrier_claims_04);
%ercp (out=ercp_carrier_19_05, in1=rifq2019.bcarrier_line_05, in2=rifq2019.bcarrier_claims_05);
%ercp (out=ercp_carrier_19_06, in1=rifq2019.bcarrier_line_06, in2=rifq2019.bcarrier_claims_06);
%ercp (out=ercp_carrier_19_07, in1=rifq2019.bcarrier_line_07, in2=rifq2019.bcarrier_claims_07);
%ercp (out=ercp_carrier_19_08, in1=rifq2019.bcarrier_line_08, in2=rifq2019.bcarrier_claims_08);
%ercp (out=ercp_carrier_19_09, in1=rifq2019.bcarrier_line_09, in2=rifq2019.bcarrier_claims_09);
%ercp (out=ercp_carrier_19_10, in1=rifq2019.bcarrier_line_10, in2=rifq2019.bcarrier_claims_10);
%ercp (out=ercp_carrier_19_11, in1=rifq2019.bcarrier_line_11, in2=rifq2019.bcarrier_claims_11);
%ercp (out=ercp_carrier_19_12, in1=rifq2019.bcarrier_line_12, in2=rifq2019.bcarrier_claims_12);

%ercp (out=ercp_carrier_20_01, in1=rifq2020.bcarrier_line_01, in2=rifq2020.bcarrier_claims_01);
%ercp (out=ercp_carrier_20_02, in1=rifq2020.bcarrier_line_02, in2=rifq2020.bcarrier_claims_02);
%ercp (out=ercp_carrier_20_03, in1=rifq2020.bcarrier_line_03, in2=rifq2020.bcarrier_claims_03);
%ercp (out=ercp_carrier_20_04, in1=rifq2020.bcarrier_line_04, in2=rifq2020.bcarrier_claims_04);
%ercp (out=ercp_carrier_20_05, in1=rifq2020.bcarrier_line_05, in2=rifq2020.bcarrier_claims_05);
%ercp (out=ercp_carrier_20_06, in1=rifq2020.bcarrier_line_06, in2=rifq2020.bcarrier_claims_06);
%ercp (out=ercp_carrier_20_07, in1=rifq2020.bcarrier_line_07, in2=rifq2020.bcarrier_claims_07);
%ercp (out=ercp_carrier_20_08, in1=rifq2020.bcarrier_line_08, in2=rifq2020.bcarrier_claims_08);
%ercp (out=ercp_carrier_20_09, in1=rifq2020.bcarrier_line_09, in2=rifq2020.bcarrier_claims_09);
%ercp (out=ercp_carrier_20_10, in1=rifq2020.bcarrier_line_10, in2=rifq2020.bcarrier_claims_10);
%ercp (out=ercp_carrier_20_11, in1=rifq2020.bcarrier_line_11, in2=rifq2020.bcarrier_claims_11);
%ercp (out=ercp_carrier_20_12, in1=rifq2020.bcarrier_line_12, in2=rifq2020.bcarrier_claims_12);
%ercp (out=ercp_carrier_21_01, in1=rifq2021.bcarrier_line_01, in2=rifq2021.bcarrier_claims_01);
%ercp (out=ercp_carrier_21_02, in1=rifq2021.bcarrier_line_02, in2=rifq2021.bcarrier_claims_02);
%ercp (out=ercp_carrier_21_03, in1=rifq2021.bcarrier_line_03, in2=rifq2021.bcarrier_claims_03);
%ercp (out=ercp_carrier_21_04, in1=rifq2021.bcarrier_line_04, in2=rifq2021.bcarrier_claims_04);
%ercp (out=ercp_carrier_21_05, in1=rifq2021.bcarrier_line_05, in2=rifq2021.bcarrier_claims_05);
%ercp (out=ercp_carrier_21_06, in1=rifq2021.bcarrier_line_06, in2=rifq2021.bcarrier_claims_06);
%ercp (out=ercp_carrier_21_07, in1=rifq2021.bcarrier_line_07, in2=rifq2021.bcarrier_claims_07);
%ercp (out=ercp_carrier_21_08, in1=rifq2021.bcarrier_line_08, in2=rifq2021.bcarrier_claims_08);
%ercp (out=ercp_carrier_21_09, in1=rifq2021.bcarrier_line_09, in2=rifq2021.bcarrier_claims_09);
%ercp (out=ercp_carrier_21_10, in1=rifq2021.bcarrier_line_10, in2=rifq2021.bcarrier_claims_10);
%ercp (out=ercp_carrier_21_11, in1=rifq2021.bcarrier_line_11, in2=rifq2021.bcarrier_claims_11);
%ercp (out=ercp_carrier_21_12, in1=rifq2021.bcarrier_line_12, in2=rifq2021.bcarrier_claims_12);

*inpatient;
%ercp (out=ercp_inpatient_15_01, in1=rif2015.inpatient_revenue_01, in2=rif2015.inpatient_claims_01);
%ercp (out=ercp_inpatient_15_02, in1=rif2015.inpatient_revenue_02, in2=rif2015.inpatient_claims_02);
%ercp (out=ercp_inpatient_15_03, in1=rif2015.inpatient_revenue_03, in2=rif2015.inpatient_claims_03);
%ercp (out=ercp_inpatient_15_04, in1=rif2015.inpatient_revenue_04, in2=rif2015.inpatient_claims_04);
%ercp (out=ercp_inpatient_15_05, in1=rif2015.inpatient_revenue_05, in2=rif2015.inpatient_claims_05);
%ercp (out=ercp_inpatient_15_06, in1=rif2015.inpatient_revenue_06, in2=rif2015.inpatient_claims_06);
%ercp (out=ercp_inpatient_15_07, in1=rif2015.inpatient_revenue_07, in2=rif2015.inpatient_claims_07);
%ercp (out=ercp_inpatient_15_08, in1=rif2015.inpatient_revenue_08, in2=rif2015.inpatient_claims_08);
%ercp (out=ercp_inpatient_15_09, in1=rif2015.inpatient_revenue_09, in2=rif2015.inpatient_claims_09);
%ercp (out=ercp_inpatient_15_10, in1=rif2015.inpatient_revenue_10, in2=rif2015.inpatient_claims_10);
%ercp (out=ercp_inpatient_15_11, in1=rif2015.inpatient_revenue_11, in2=rif2015.inpatient_claims_11);
%ercp (out=ercp_inpatient_15_12, in1=rif2015.inpatient_revenue_12, in2=rif2015.inpatient_claims_12);

%ercp (out=ercp_inpatient_16_01, in1=rif2016.inpatient_revenue_01, in2=rif2016.inpatient_claims_01);
%ercp (out=ercp_inpatient_16_02, in1=rif2016.inpatient_revenue_02, in2=rif2016.inpatient_claims_02);
%ercp (out=ercp_inpatient_16_03, in1=rif2016.inpatient_revenue_03, in2=rif2016.inpatient_claims_03);
%ercp (out=ercp_inpatient_16_04, in1=rif2016.inpatient_revenue_04, in2=rif2016.inpatient_claims_04);
%ercp (out=ercp_inpatient_16_05, in1=rif2016.inpatient_revenue_05, in2=rif2016.inpatient_claims_05);
%ercp (out=ercp_inpatient_16_06, in1=rif2016.inpatient_revenue_06, in2=rif2016.inpatient_claims_06);
%ercp (out=ercp_inpatient_16_07, in1=rif2016.inpatient_revenue_07, in2=rif2016.inpatient_claims_07);
%ercp (out=ercp_inpatient_16_08, in1=rif2016.inpatient_revenue_08, in2=rif2016.inpatient_claims_08);
%ercp (out=ercp_inpatient_16_09, in1=rif2016.inpatient_revenue_09, in2=rif2016.inpatient_claims_09);
%ercp (out=ercp_inpatient_16_10, in1=rif2016.inpatient_revenue_10, in2=rif2016.inpatient_claims_10);
%ercp (out=ercp_inpatient_16_11, in1=rif2016.inpatient_revenue_11, in2=rif2016.inpatient_claims_11);
%ercp (out=ercp_inpatient_16_12, in1=rif2016.inpatient_revenue_12, in2=rif2016.inpatient_claims_12);

%ercp (out=ercp_inpatient_17_01, in1=rif2017.inpatient_revenue_01, in2=rif2017.inpatient_claims_01);
%ercp (out=ercp_inpatient_17_02, in1=rif2017.inpatient_revenue_02, in2=rif2017.inpatient_claims_02);
%ercp (out=ercp_inpatient_17_03, in1=rif2017.inpatient_revenue_03, in2=rif2017.inpatient_claims_03);
%ercp (out=ercp_inpatient_17_04, in1=rif2017.inpatient_revenue_04, in2=rif2017.inpatient_claims_04);
%ercp (out=ercp_inpatient_17_05, in1=rif2017.inpatient_revenue_05, in2=rif2017.inpatient_claims_05);
%ercp (out=ercp_inpatient_17_06, in1=rif2017.inpatient_revenue_06, in2=rif2017.inpatient_claims_06);
%ercp (out=ercp_inpatient_17_07, in1=rif2017.inpatient_revenue_07, in2=rif2017.inpatient_claims_07);
%ercp (out=ercp_inpatient_17_08, in1=rif2017.inpatient_revenue_08, in2=rif2017.inpatient_claims_08);
%ercp (out=ercp_inpatient_17_09, in1=rif2017.inpatient_revenue_09, in2=rif2017.inpatient_claims_09);
%ercp (out=ercp_inpatient_17_10, in1=rif2017.inpatient_revenue_10, in2=rif2017.inpatient_claims_10);
%ercp (out=ercp_inpatient_17_11, in1=rif2017.inpatient_revenue_11, in2=rif2017.inpatient_claims_11);
%ercp (out=ercp_inpatient_17_12, in1=rif2017.inpatient_revenue_12, in2=rif2017.inpatient_claims_12);

%ercp (out=ercp_inpatient_18_01, in1=rifq2018.inpatient_revenue_01, in2=rifq2018.inpatient_claims_01);
%ercp (out=ercp_inpatient_18_02, in1=rifq2018.inpatient_revenue_02, in2=rifq2018.inpatient_claims_02);
%ercp (out=ercp_inpatient_18_03, in1=rifq2018.inpatient_revenue_03, in2=rifq2018.inpatient_claims_03);
%ercp (out=ercp_inpatient_18_04, in1=rifq2018.inpatient_revenue_04, in2=rifq2018.inpatient_claims_04);
%ercp (out=ercp_inpatient_18_05, in1=rifq2018.inpatient_revenue_05, in2=rifq2018.inpatient_claims_05);
%ercp (out=ercp_inpatient_18_06, in1=rifq2018.inpatient_revenue_06, in2=rifq2018.inpatient_claims_06);
%ercp (out=ercp_inpatient_18_07, in1=rifq2018.inpatient_revenue_07, in2=rifq2018.inpatient_claims_07);
%ercp (out=ercp_inpatient_18_08, in1=rifq2018.inpatient_revenue_08, in2=rifq2018.inpatient_claims_08);
%ercp (out=ercp_inpatient_18_09, in1=rifq2018.inpatient_revenue_09, in2=rifq2018.inpatient_claims_09);
%ercp (out=ercp_inpatient_18_10, in1=rifq2018.inpatient_revenue_10, in2=rifq2018.inpatient_claims_10);
%ercp (out=ercp_inpatient_18_11, in1=rifq2018.inpatient_revenue_11, in2=rifq2018.inpatient_claims_11);
%ercp (out=ercp_inpatient_18_12, in1=rifq2018.inpatient_revenue_12, in2=rifq2018.inpatient_claims_12);

%ercp (out=ercp_inpatient_19_01, in1=rifq2019.inpatient_revenue_01, in2=rifq2019.inpatient_claims_01);
%ercp (out=ercp_inpatient_19_02, in1=rifq2019.inpatient_revenue_02, in2=rifq2019.inpatient_claims_02);
%ercp (out=ercp_inpatient_19_03, in1=rifq2019.inpatient_revenue_03, in2=rifq2019.inpatient_claims_03);
%ercp (out=ercp_inpatient_19_04, in1=rifq2019.inpatient_revenue_04, in2=rifq2019.inpatient_claims_04);
%ercp (out=ercp_inpatient_19_05, in1=rifq2019.inpatient_revenue_05, in2=rifq2019.inpatient_claims_05);
%ercp (out=ercp_inpatient_19_06, in1=rifq2019.inpatient_revenue_06, in2=rifq2019.inpatient_claims_06);
%ercp (out=ercp_inpatient_19_07, in1=rifq2019.inpatient_revenue_07, in2=rifq2019.inpatient_claims_07);
%ercp (out=ercp_inpatient_19_08, in1=rifq2019.inpatient_revenue_08, in2=rifq2019.inpatient_claims_08);
%ercp (out=ercp_inpatient_19_09, in1=rifq2019.inpatient_revenue_09, in2=rifq2019.inpatient_claims_09);
%ercp (out=ercp_inpatient_19_10, in1=rifq2019.inpatient_revenue_10, in2=rifq2019.inpatient_claims_10);
%ercp (out=ercp_inpatient_19_11, in1=rifq2019.inpatient_revenue_11, in2=rifq2019.inpatient_claims_11);
%ercp (out=ercp_inpatient_19_12, in1=rifq2019.inpatient_revenue_12, in2=rifq2019.inpatient_claims_12);

%ercp (out=ercp_inpatient_20_01, in1=rifq2020.inpatient_revenue_01, in2=rifq2020.inpatient_claims_01);
%ercp (out=ercp_inpatient_20_02, in1=rifq2020.inpatient_revenue_02, in2=rifq2020.inpatient_claims_02);
%ercp (out=ercp_inpatient_20_03, in1=rifq2020.inpatient_revenue_03, in2=rifq2020.inpatient_claims_03);
%ercp (out=ercp_inpatient_20_04, in1=rifq2020.inpatient_revenue_04, in2=rifq2020.inpatient_claims_04);
%ercp (out=ercp_inpatient_20_05, in1=rifq2020.inpatient_revenue_05, in2=rifq2020.inpatient_claims_05);
%ercp (out=ercp_inpatient_20_06, in1=rifq2020.inpatient_revenue_06, in2=rifq2020.inpatient_claims_06);
%ercp (out=ercp_inpatient_20_07, in1=rifq2020.inpatient_revenue_07, in2=rifq2020.inpatient_claims_07);
%ercp (out=ercp_inpatient_20_08, in1=rifq2020.inpatient_revenue_08, in2=rifq2020.inpatient_claims_08);
%ercp (out=ercp_inpatient_20_09, in1=rifq2020.inpatient_revenue_09, in2=rifq2020.inpatient_claims_09);
%ercp (out=ercp_inpatient_20_10, in1=rifq2020.inpatient_revenue_10, in2=rifq2020.inpatient_claims_10);
%ercp (out=ercp_inpatient_20_11, in1=rifq2020.inpatient_revenue_11, in2=rifq2020.inpatient_claims_11);
%ercp (out=ercp_inpatient_20_12, in1=rifq2020.inpatient_revenue_12, in2=rifq2020.inpatient_claims_12);
%ercp (out=ercp_inpatient_21_01, in1=rifq2021.inpatient_revenue_01, in2=rifq2021.inpatient_claims_01);
%ercp (out=ercp_inpatient_21_02, in1=rifq2021.inpatient_revenue_02, in2=rifq2021.inpatient_claims_02);
%ercp (out=ercp_inpatient_21_03, in1=rifq2021.inpatient_revenue_03, in2=rifq2021.inpatient_claims_03);
%ercp (out=ercp_inpatient_21_04, in1=rifq2021.inpatient_revenue_04, in2=rifq2021.inpatient_claims_04);
%ercp (out=ercp_inpatient_21_05, in1=rifq2021.inpatient_revenue_05, in2=rifq2021.inpatient_claims_05);
%ercp (out=ercp_inpatient_21_06, in1=rifq2021.inpatient_revenue_06, in2=rifq2021.inpatient_claims_06);
%ercp (out=ercp_inpatient_21_07, in1=rifq2021.inpatient_revenue_07, in2=rifq2021.inpatient_claims_07);
%ercp (out=ercp_inpatient_21_08, in1=rifq2021.inpatient_revenue_08, in2=rifq2021.inpatient_claims_08);
%ercp (out=ercp_inpatient_21_09, in1=rifq2021.inpatient_revenue_09, in2=rifq2021.inpatient_claims_09);
%ercp (out=ercp_inpatient_21_10, in1=rifq2021.inpatient_revenue_10, in2=rifq2021.inpatient_claims_10);
%ercp (out=ercp_inpatient_21_11, in1=rifq2021.inpatient_revenue_11, in2=rifq2021.inpatient_claims_11);
%ercp (out=ercp_inpatient_21_12, in1=rifq2021.inpatient_revenue_12, in2=rifq2021.inpatient_claims_12);

*outpatient;
%ercp (out=ercp_outpatient_15_01, in1=rif2015.outpatient_revenue_01, in2=rif2015.outpatient_claims_01);
%ercp (out=ercp_outpatient_15_02, in1=rif2015.outpatient_revenue_02, in2=rif2015.outpatient_claims_02);
%ercp (out=ercp_outpatient_15_03, in1=rif2015.outpatient_revenue_03, in2=rif2015.outpatient_claims_03);
%ercp (out=ercp_outpatient_15_04, in1=rif2015.outpatient_revenue_04, in2=rif2015.outpatient_claims_04);
%ercp (out=ercp_outpatient_15_05, in1=rif2015.outpatient_revenue_05, in2=rif2015.outpatient_claims_05);
%ercp (out=ercp_outpatient_15_06, in1=rif2015.outpatient_revenue_06, in2=rif2015.outpatient_claims_06);
%ercp (out=ercp_outpatient_15_07, in1=rif2015.outpatient_revenue_07, in2=rif2015.outpatient_claims_07);
%ercp (out=ercp_outpatient_15_08, in1=rif2015.outpatient_revenue_08, in2=rif2015.outpatient_claims_08);
%ercp (out=ercp_outpatient_15_09, in1=rif2015.outpatient_revenue_09, in2=rif2015.outpatient_claims_09);
%ercp (out=ercp_outpatient_15_10, in1=rif2015.outpatient_revenue_10, in2=rif2015.outpatient_claims_10);
%ercp (out=ercp_outpatient_15_11, in1=rif2015.outpatient_revenue_11, in2=rif2015.outpatient_claims_11);
%ercp (out=ercp_outpatient_15_12, in1=rif2015.outpatient_revenue_12, in2=rif2015.outpatient_claims_12);

%ercp (out=ercp_outpatient_16_01, in1=rif2016.outpatient_revenue_01, in2=rif2016.outpatient_claims_01);
%ercp (out=ercp_outpatient_16_02, in1=rif2016.outpatient_revenue_02, in2=rif2016.outpatient_claims_02);
%ercp (out=ercp_outpatient_16_03, in1=rif2016.outpatient_revenue_03, in2=rif2016.outpatient_claims_03);
%ercp (out=ercp_outpatient_16_04, in1=rif2016.outpatient_revenue_04, in2=rif2016.outpatient_claims_04);
%ercp (out=ercp_outpatient_16_05, in1=rif2016.outpatient_revenue_05, in2=rif2016.outpatient_claims_05);
%ercp (out=ercp_outpatient_16_06, in1=rif2016.outpatient_revenue_06, in2=rif2016.outpatient_claims_06);
%ercp (out=ercp_outpatient_16_07, in1=rif2016.outpatient_revenue_07, in2=rif2016.outpatient_claims_07);
%ercp (out=ercp_outpatient_16_08, in1=rif2016.outpatient_revenue_08, in2=rif2016.outpatient_claims_08);
%ercp (out=ercp_outpatient_16_09, in1=rif2016.outpatient_revenue_09, in2=rif2016.outpatient_claims_09);
%ercp (out=ercp_outpatient_16_10, in1=rif2016.outpatient_revenue_10, in2=rif2016.outpatient_claims_10);
%ercp (out=ercp_outpatient_16_11, in1=rif2016.outpatient_revenue_11, in2=rif2016.outpatient_claims_11);
%ercp (out=ercp_outpatient_16_12, in1=rif2016.outpatient_revenue_12, in2=rif2016.outpatient_claims_12);

%ercp (out=ercp_outpatient_17_01, in1=rif2017.outpatient_revenue_01, in2=rif2017.outpatient_claims_01);
%ercp (out=ercp_outpatient_17_02, in1=rif2017.outpatient_revenue_02, in2=rif2017.outpatient_claims_02);
%ercp (out=ercp_outpatient_17_03, in1=rif2017.outpatient_revenue_03, in2=rif2017.outpatient_claims_03);
%ercp (out=ercp_outpatient_17_04, in1=rif2017.outpatient_revenue_04, in2=rif2017.outpatient_claims_04);
%ercp (out=ercp_outpatient_17_05, in1=rif2017.outpatient_revenue_05, in2=rif2017.outpatient_claims_05);
%ercp (out=ercp_outpatient_17_06, in1=rif2017.outpatient_revenue_06, in2=rif2017.outpatient_claims_06);
%ercp (out=ercp_outpatient_17_07, in1=rif2017.outpatient_revenue_07, in2=rif2017.outpatient_claims_07);
%ercp (out=ercp_outpatient_17_08, in1=rif2017.outpatient_revenue_08, in2=rif2017.outpatient_claims_08);
%ercp (out=ercp_outpatient_17_09, in1=rif2017.outpatient_revenue_09, in2=rif2017.outpatient_claims_09);
%ercp (out=ercp_outpatient_17_10, in1=rif2017.outpatient_revenue_10, in2=rif2017.outpatient_claims_10);
%ercp (out=ercp_outpatient_17_11, in1=rif2017.outpatient_revenue_11, in2=rif2017.outpatient_claims_11);
%ercp (out=ercp_outpatient_17_12, in1=rif2017.outpatient_revenue_12, in2=rif2017.outpatient_claims_12);

%ercp (out=ercp_outpatient_18_01, in1=rifq2018.outpatient_revenue_01, in2=rifq2018.outpatient_claims_01);
%ercp (out=ercp_outpatient_18_02, in1=rifq2018.outpatient_revenue_02, in2=rifq2018.outpatient_claims_02);
%ercp (out=ercp_outpatient_18_03, in1=rifq2018.outpatient_revenue_03, in2=rifq2018.outpatient_claims_03);
%ercp (out=ercp_outpatient_18_04, in1=rifq2018.outpatient_revenue_04, in2=rifq2018.outpatient_claims_04);
%ercp (out=ercp_outpatient_18_05, in1=rifq2018.outpatient_revenue_05, in2=rifq2018.outpatient_claims_05);
%ercp (out=ercp_outpatient_18_06, in1=rifq2018.outpatient_revenue_06, in2=rifq2018.outpatient_claims_06);
%ercp (out=ercp_outpatient_18_07, in1=rifq2018.outpatient_revenue_07, in2=rifq2018.outpatient_claims_07);
%ercp (out=ercp_outpatient_18_08, in1=rifq2018.outpatient_revenue_08, in2=rifq2018.outpatient_claims_08);
%ercp (out=ercp_outpatient_18_09, in1=rifq2018.outpatient_revenue_09, in2=rifq2018.outpatient_claims_09);
%ercp (out=ercp_outpatient_18_10, in1=rifq2018.outpatient_revenue_10, in2=rifq2018.outpatient_claims_10);
%ercp (out=ercp_outpatient_18_11, in1=rifq2018.outpatient_revenue_11, in2=rifq2018.outpatient_claims_11);
%ercp (out=ercp_outpatient_18_12, in1=rifq2018.outpatient_revenue_12, in2=rifq2018.outpatient_claims_12);

%ercp (out=ercp_outpatient_19_01, in1=rifq2019.outpatient_revenue_01, in2=rifq2019.outpatient_claims_01);
%ercp (out=ercp_outpatient_19_02, in1=rifq2019.outpatient_revenue_02, in2=rifq2019.outpatient_claims_02);
%ercp (out=ercp_outpatient_19_03, in1=rifq2019.outpatient_revenue_03, in2=rifq2019.outpatient_claims_03);
%ercp (out=ercp_outpatient_19_04, in1=rifq2019.outpatient_revenue_04, in2=rifq2019.outpatient_claims_04);
%ercp (out=ercp_outpatient_19_05, in1=rifq2019.outpatient_revenue_05, in2=rifq2019.outpatient_claims_05);
%ercp (out=ercp_outpatient_19_06, in1=rifq2019.outpatient_revenue_06, in2=rifq2019.outpatient_claims_06);
%ercp (out=ercp_outpatient_19_07, in1=rifq2019.outpatient_revenue_07, in2=rifq2019.outpatient_claims_07);
%ercp (out=ercp_outpatient_19_08, in1=rifq2019.outpatient_revenue_08, in2=rifq2019.outpatient_claims_08);
%ercp (out=ercp_outpatient_19_09, in1=rifq2019.outpatient_revenue_09, in2=rifq2019.outpatient_claims_09);
%ercp (out=ercp_outpatient_19_10, in1=rifq2019.outpatient_revenue_10, in2=rifq2019.outpatient_claims_10);
%ercp (out=ercp_outpatient_19_11, in1=rifq2019.outpatient_revenue_11, in2=rifq2019.outpatient_claims_11);
%ercp (out=ercp_outpatient_19_12, in1=rifq2019.outpatient_revenue_12, in2=rifq2019.outpatient_claims_12);

%ercp (out=ercp_outpatient_20_01, in1=rifq2020.outpatient_revenue_01, in2=rifq2020.outpatient_claims_01);
%ercp (out=ercp_outpatient_20_02, in1=rifq2020.outpatient_revenue_02, in2=rifq2020.outpatient_claims_02);
%ercp (out=ercp_outpatient_20_03, in1=rifq2020.outpatient_revenue_03, in2=rifq2020.outpatient_claims_03);
%ercp (out=ercp_outpatient_20_04, in1=rifq2020.outpatient_revenue_04, in2=rifq2020.outpatient_claims_04);
%ercp (out=ercp_outpatient_20_05, in1=rifq2020.outpatient_revenue_05, in2=rifq2020.outpatient_claims_05);
%ercp (out=ercp_outpatient_20_06, in1=rifq2020.outpatient_revenue_06, in2=rifq2020.outpatient_claims_06);
%ercp (out=ercp_outpatient_20_07, in1=rifq2020.outpatient_revenue_07, in2=rifq2020.outpatient_claims_07);
%ercp (out=ercp_outpatient_20_08, in1=rifq2020.outpatient_revenue_08, in2=rifq2020.outpatient_claims_08);
%ercp (out=ercp_outpatient_20_09, in1=rifq2020.outpatient_revenue_09, in2=rifq2020.outpatient_claims_09);
%ercp (out=ercp_outpatient_20_10, in1=rifq2020.outpatient_revenue_10, in2=rifq2020.outpatient_claims_10);
%ercp (out=ercp_outpatient_20_11, in1=rifq2020.outpatient_revenue_11, in2=rifq2020.outpatient_claims_11);
%ercp (out=ercp_outpatient_20_12, in1=rifq2020.outpatient_revenue_12, in2=rifq2020.outpatient_claims_12);
%ercp (out=ercp_outpatient_21_01, in1=rifq2021.outpatient_revenue_01, in2=rifq2021.outpatient_claims_01);
%ercp (out=ercp_outpatient_21_02, in1=rifq2021.outpatient_revenue_02, in2=rifq2021.outpatient_claims_02);
%ercp (out=ercp_outpatient_21_03, in1=rifq2021.outpatient_revenue_03, in2=rifq2021.outpatient_claims_03);
%ercp (out=ercp_outpatient_21_04, in1=rifq2021.outpatient_revenue_04, in2=rifq2021.outpatient_claims_04);
%ercp (out=ercp_outpatient_21_05, in1=rifq2021.outpatient_revenue_05, in2=rifq2021.outpatient_claims_05);
%ercp (out=ercp_outpatient_21_06, in1=rifq2021.outpatient_revenue_06, in2=rifq2021.outpatient_claims_06);
%ercp (out=ercp_outpatient_21_07, in1=rifq2021.outpatient_revenue_07, in2=rifq2021.outpatient_claims_07);
%ercp (out=ercp_outpatient_21_08, in1=rifq2021.outpatient_revenue_08, in2=rifq2021.outpatient_claims_08);
%ercp (out=ercp_outpatient_21_09, in1=rifq2021.outpatient_revenue_09, in2=rifq2021.outpatient_claims_09);
%ercp (out=ercp_outpatient_21_10, in1=rifq2021.outpatient_revenue_10, in2=rifq2021.outpatient_claims_10);
%ercp (out=ercp_outpatient_21_11, in1=rifq2021.outpatient_revenue_11, in2=rifq2021.outpatient_claims_11);
%ercp (out=ercp_outpatient_21_12, in1=rifq2021.outpatient_revenue_12, in2=rifq2021.outpatient_claims_12);


*start--identifying from icd procedure;
%macro ercp (out=, in1=, in2=);
proc sql;
	create table temp as
	select *
	from &in2    
	where  icd_prcdr_cd1 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd2 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd3 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd4 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd5 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd6 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd7 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd8 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd9 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd10 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd11 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd12 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd13 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd14 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd15 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd16 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd17 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd18 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd19 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd20 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd21 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd22 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd23 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd24 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
		or icd_prcdr_cd25 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
;
quit;
proc sql;
	create table &out as
	select *
	from temp a,
	&in1 b 
	where a.bene_id = b.bene_id and a.clm_id = b.clm_id;
quit;
%mend;
*inpatient;
%ercp (out=ercp_inpatientICD_15_01, in1=rif2015.inpatient_revenue_01, in2=rif2015.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_15_02, in1=rif2015.inpatient_revenue_02, in2=rif2015.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_15_03, in1=rif2015.inpatient_revenue_03, in2=rif2015.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_15_04, in1=rif2015.inpatient_revenue_04, in2=rif2015.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_15_05, in1=rif2015.inpatient_revenue_05, in2=rif2015.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_15_06, in1=rif2015.inpatient_revenue_06, in2=rif2015.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_15_07, in1=rif2015.inpatient_revenue_07, in2=rif2015.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_15_08, in1=rif2015.inpatient_revenue_08, in2=rif2015.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_15_09, in1=rif2015.inpatient_revenue_09, in2=rif2015.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_15_10, in1=rif2015.inpatient_revenue_10, in2=rif2015.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_15_11, in1=rif2015.inpatient_revenue_11, in2=rif2015.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_15_12, in1=rif2015.inpatient_revenue_12, in2=rif2015.inpatient_claims_12);

%ercp (out=ercp_inpatientICD_16_01, in1=rif2016.inpatient_revenue_01, in2=rif2016.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_16_02, in1=rif2016.inpatient_revenue_02, in2=rif2016.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_16_03, in1=rif2016.inpatient_revenue_03, in2=rif2016.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_16_04, in1=rif2016.inpatient_revenue_04, in2=rif2016.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_16_05, in1=rif2016.inpatient_revenue_05, in2=rif2016.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_16_06, in1=rif2016.inpatient_revenue_06, in2=rif2016.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_16_07, in1=rif2016.inpatient_revenue_07, in2=rif2016.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_16_08, in1=rif2016.inpatient_revenue_08, in2=rif2016.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_16_09, in1=rif2016.inpatient_revenue_09, in2=rif2016.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_16_10, in1=rif2016.inpatient_revenue_10, in2=rif2016.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_16_11, in1=rif2016.inpatient_revenue_11, in2=rif2016.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_16_12, in1=rif2016.inpatient_revenue_12, in2=rif2016.inpatient_claims_12);

%ercp (out=ercp_inpatientICD_17_01, in1=rif2017.inpatient_revenue_01, in2=rif2017.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_17_02, in1=rif2017.inpatient_revenue_02, in2=rif2017.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_17_03, in1=rif2017.inpatient_revenue_03, in2=rif2017.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_17_04, in1=rif2017.inpatient_revenue_04, in2=rif2017.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_17_05, in1=rif2017.inpatient_revenue_05, in2=rif2017.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_17_06, in1=rif2017.inpatient_revenue_06, in2=rif2017.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_17_07, in1=rif2017.inpatient_revenue_07, in2=rif2017.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_17_08, in1=rif2017.inpatient_revenue_08, in2=rif2017.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_17_09, in1=rif2017.inpatient_revenue_09, in2=rif2017.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_17_10, in1=rif2017.inpatient_revenue_10, in2=rif2017.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_17_11, in1=rif2017.inpatient_revenue_11, in2=rif2017.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_17_12, in1=rif2017.inpatient_revenue_12, in2=rif2017.inpatient_claims_12);

%ercp (out=ercp_inpatientICD_18_01, in1=rifq2018.inpatient_revenue_01, in2=rifq2018.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_18_02, in1=rifq2018.inpatient_revenue_02, in2=rifq2018.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_18_03, in1=rifq2018.inpatient_revenue_03, in2=rifq2018.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_18_04, in1=rifq2018.inpatient_revenue_04, in2=rifq2018.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_18_05, in1=rifq2018.inpatient_revenue_05, in2=rifq2018.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_18_06, in1=rifq2018.inpatient_revenue_06, in2=rifq2018.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_18_07, in1=rifq2018.inpatient_revenue_07, in2=rifq2018.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_18_08, in1=rifq2018.inpatient_revenue_08, in2=rifq2018.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_18_09, in1=rifq2018.inpatient_revenue_09, in2=rifq2018.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_18_10, in1=rifq2018.inpatient_revenue_10, in2=rifq2018.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_18_11, in1=rifq2018.inpatient_revenue_11, in2=rifq2018.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_18_12, in1=rifq2018.inpatient_revenue_12, in2=rifq2018.inpatient_claims_12);

%ercp (out=ercp_inpatientICD_19_01, in1=rifq2019.inpatient_revenue_01, in2=rifq2019.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_19_02, in1=rifq2019.inpatient_revenue_02, in2=rifq2019.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_19_03, in1=rifq2019.inpatient_revenue_03, in2=rifq2019.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_19_04, in1=rifq2019.inpatient_revenue_04, in2=rifq2019.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_19_05, in1=rifq2019.inpatient_revenue_05, in2=rifq2019.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_19_06, in1=rifq2019.inpatient_revenue_06, in2=rifq2019.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_19_07, in1=rifq2019.inpatient_revenue_07, in2=rifq2019.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_19_08, in1=rifq2019.inpatient_revenue_08, in2=rifq2019.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_19_09, in1=rifq2019.inpatient_revenue_09, in2=rifq2019.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_19_10, in1=rifq2019.inpatient_revenue_10, in2=rifq2019.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_19_11, in1=rifq2019.inpatient_revenue_11, in2=rifq2019.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_19_12, in1=rifq2019.inpatient_revenue_12, in2=rifq2019.inpatient_claims_12);

%ercp (out=ercp_inpatientICD_20_01, in1=rifq2020.inpatient_revenue_01, in2=rifq2020.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_20_02, in1=rifq2020.inpatient_revenue_02, in2=rifq2020.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_20_03, in1=rifq2020.inpatient_revenue_03, in2=rifq2020.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_20_04, in1=rifq2020.inpatient_revenue_04, in2=rifq2020.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_20_05, in1=rifq2020.inpatient_revenue_05, in2=rifq2020.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_20_06, in1=rifq2020.inpatient_revenue_06, in2=rifq2020.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_20_07, in1=rifq2020.inpatient_revenue_07, in2=rifq2020.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_20_08, in1=rifq2020.inpatient_revenue_08, in2=rifq2020.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_20_09, in1=rifq2020.inpatient_revenue_09, in2=rifq2020.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_20_10, in1=rifq2020.inpatient_revenue_10, in2=rifq2020.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_20_11, in1=rifq2020.inpatient_revenue_11, in2=rifq2020.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_20_12, in1=rifq2020.inpatient_revenue_12, in2=rifq2020.inpatient_claims_12);
%ercp (out=ercp_inpatientICD_21_01, in1=rifq2021.inpatient_revenue_01, in2=rifq2021.inpatient_claims_01);
%ercp (out=ercp_inpatientICD_21_02, in1=rifq2021.inpatient_revenue_02, in2=rifq2021.inpatient_claims_02);
%ercp (out=ercp_inpatientICD_21_03, in1=rifq2021.inpatient_revenue_03, in2=rifq2021.inpatient_claims_03);
%ercp (out=ercp_inpatientICD_21_04, in1=rifq2021.inpatient_revenue_04, in2=rifq2021.inpatient_claims_04);
%ercp (out=ercp_inpatientICD_21_05, in1=rifq2021.inpatient_revenue_05, in2=rifq2021.inpatient_claims_05);
%ercp (out=ercp_inpatientICD_21_06, in1=rifq2021.inpatient_revenue_06, in2=rifq2021.inpatient_claims_06);
%ercp (out=ercp_inpatientICD_21_07, in1=rifq2021.inpatient_revenue_07, in2=rifq2021.inpatient_claims_07);
%ercp (out=ercp_inpatientICD_21_08, in1=rifq2021.inpatient_revenue_08, in2=rifq2021.inpatient_claims_08);
%ercp (out=ercp_inpatientICD_21_09, in1=rifq2021.inpatient_revenue_09, in2=rifq2021.inpatient_claims_09);
%ercp (out=ercp_inpatientICD_21_10, in1=rifq2021.inpatient_revenue_10, in2=rifq2021.inpatient_claims_10);
%ercp (out=ercp_inpatientICD_21_11, in1=rifq2021.inpatient_revenue_11, in2=rifq2021.inpatient_claims_11);
%ercp (out=ercp_inpatientICD_21_12, in1=rifq2021.inpatient_revenue_12, in2=rifq2021.inpatient_claims_12);

*outpatient;
%ercp (out=ercp_outpatientICD_15_01, in1=rif2015.outpatient_revenue_01, in2=rif2015.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_15_02, in1=rif2015.outpatient_revenue_02, in2=rif2015.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_15_03, in1=rif2015.outpatient_revenue_03, in2=rif2015.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_15_04, in1=rif2015.outpatient_revenue_04, in2=rif2015.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_15_05, in1=rif2015.outpatient_revenue_05, in2=rif2015.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_15_06, in1=rif2015.outpatient_revenue_06, in2=rif2015.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_15_07, in1=rif2015.outpatient_revenue_07, in2=rif2015.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_15_08, in1=rif2015.outpatient_revenue_08, in2=rif2015.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_15_09, in1=rif2015.outpatient_revenue_09, in2=rif2015.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_15_10, in1=rif2015.outpatient_revenue_10, in2=rif2015.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_15_11, in1=rif2015.outpatient_revenue_11, in2=rif2015.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_15_12, in1=rif2015.outpatient_revenue_12, in2=rif2015.outpatient_claims_12);

%ercp (out=ercp_outpatientICD_16_01, in1=rif2016.outpatient_revenue_01, in2=rif2016.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_16_02, in1=rif2016.outpatient_revenue_02, in2=rif2016.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_16_03, in1=rif2016.outpatient_revenue_03, in2=rif2016.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_16_04, in1=rif2016.outpatient_revenue_04, in2=rif2016.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_16_05, in1=rif2016.outpatient_revenue_05, in2=rif2016.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_16_06, in1=rif2016.outpatient_revenue_06, in2=rif2016.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_16_07, in1=rif2016.outpatient_revenue_07, in2=rif2016.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_16_08, in1=rif2016.outpatient_revenue_08, in2=rif2016.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_16_09, in1=rif2016.outpatient_revenue_09, in2=rif2016.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_16_10, in1=rif2016.outpatient_revenue_10, in2=rif2016.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_16_11, in1=rif2016.outpatient_revenue_11, in2=rif2016.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_16_12, in1=rif2016.outpatient_revenue_12, in2=rif2016.outpatient_claims_12);

%ercp (out=ercp_outpatientICD_17_01, in1=rif2017.outpatient_revenue_01, in2=rif2017.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_17_02, in1=rif2017.outpatient_revenue_02, in2=rif2017.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_17_03, in1=rif2017.outpatient_revenue_03, in2=rif2017.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_17_04, in1=rif2017.outpatient_revenue_04, in2=rif2017.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_17_05, in1=rif2017.outpatient_revenue_05, in2=rif2017.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_17_06, in1=rif2017.outpatient_revenue_06, in2=rif2017.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_17_07, in1=rif2017.outpatient_revenue_07, in2=rif2017.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_17_08, in1=rif2017.outpatient_revenue_08, in2=rif2017.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_17_09, in1=rif2017.outpatient_revenue_09, in2=rif2017.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_17_10, in1=rif2017.outpatient_revenue_10, in2=rif2017.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_17_11, in1=rif2017.outpatient_revenue_11, in2=rif2017.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_17_12, in1=rif2017.outpatient_revenue_12, in2=rif2017.outpatient_claims_12);

%ercp (out=ercp_outpatientICD_18_01, in1=rifq2018.outpatient_revenue_01, in2=rifq2018.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_18_02, in1=rifq2018.outpatient_revenue_02, in2=rifq2018.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_18_03, in1=rifq2018.outpatient_revenue_03, in2=rifq2018.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_18_04, in1=rifq2018.outpatient_revenue_04, in2=rifq2018.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_18_05, in1=rifq2018.outpatient_revenue_05, in2=rifq2018.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_18_06, in1=rifq2018.outpatient_revenue_06, in2=rifq2018.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_18_07, in1=rifq2018.outpatient_revenue_07, in2=rifq2018.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_18_08, in1=rifq2018.outpatient_revenue_08, in2=rifq2018.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_18_09, in1=rifq2018.outpatient_revenue_09, in2=rifq2018.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_18_10, in1=rifq2018.outpatient_revenue_10, in2=rifq2018.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_18_11, in1=rifq2018.outpatient_revenue_11, in2=rifq2018.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_18_12, in1=rifq2018.outpatient_revenue_12, in2=rifq2018.outpatient_claims_12);

%ercp (out=ercp_outpatientICD_19_01, in1=rifq2019.outpatient_revenue_01, in2=rifq2019.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_19_02, in1=rifq2019.outpatient_revenue_02, in2=rifq2019.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_19_03, in1=rifq2019.outpatient_revenue_03, in2=rifq2019.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_19_04, in1=rifq2019.outpatient_revenue_04, in2=rifq2019.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_19_05, in1=rifq2019.outpatient_revenue_05, in2=rifq2019.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_19_06, in1=rifq2019.outpatient_revenue_06, in2=rifq2019.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_19_07, in1=rifq2019.outpatient_revenue_07, in2=rifq2019.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_19_08, in1=rifq2019.outpatient_revenue_08, in2=rifq2019.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_19_09, in1=rifq2019.outpatient_revenue_09, in2=rifq2019.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_19_10, in1=rifq2019.outpatient_revenue_10, in2=rifq2019.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_19_11, in1=rifq2019.outpatient_revenue_11, in2=rifq2019.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_19_12, in1=rifq2019.outpatient_revenue_12, in2=rifq2019.outpatient_claims_12);

%ercp (out=ercp_outpatientICD_20_01, in1=rifq2020.outpatient_revenue_01, in2=rifq2020.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_20_02, in1=rifq2020.outpatient_revenue_02, in2=rifq2020.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_20_03, in1=rifq2020.outpatient_revenue_03, in2=rifq2020.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_20_04, in1=rifq2020.outpatient_revenue_04, in2=rifq2020.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_20_05, in1=rifq2020.outpatient_revenue_05, in2=rifq2020.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_20_06, in1=rifq2020.outpatient_revenue_06, in2=rifq2020.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_20_07, in1=rifq2020.outpatient_revenue_07, in2=rifq2020.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_20_08, in1=rifq2020.outpatient_revenue_08, in2=rifq2020.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_20_09, in1=rifq2020.outpatient_revenue_09, in2=rifq2020.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_20_10, in1=rifq2020.outpatient_revenue_10, in2=rifq2020.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_20_11, in1=rifq2020.outpatient_revenue_11, in2=rifq2020.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_20_12, in1=rifq2020.outpatient_revenue_12, in2=rifq2020.outpatient_claims_12);
%ercp (out=ercp_outpatientICD_21_01, in1=rifq2021.outpatient_revenue_01, in2=rifq2021.outpatient_claims_01);
%ercp (out=ercp_outpatientICD_21_02, in1=rifq2021.outpatient_revenue_02, in2=rifq2021.outpatient_claims_02);
%ercp (out=ercp_outpatientICD_21_03, in1=rifq2021.outpatient_revenue_03, in2=rifq2021.outpatient_claims_03);
%ercp (out=ercp_outpatientICD_21_04, in1=rifq2021.outpatient_revenue_04, in2=rifq2021.outpatient_claims_04);
%ercp (out=ercp_outpatientICD_21_05, in1=rifq2021.outpatient_revenue_05, in2=rifq2021.outpatient_claims_05);
%ercp (out=ercp_outpatientICD_21_06, in1=rifq2021.outpatient_revenue_06, in2=rifq2021.outpatient_claims_06);
%ercp (out=ercp_outpatientICD_21_07, in1=rifq2021.outpatient_revenue_07, in2=rifq2021.outpatient_claims_07);
%ercp (out=ercp_outpatientICD_21_08, in1=rifq2021.outpatient_revenue_08, in2=rifq2021.outpatient_claims_08);
%ercp (out=ercp_outpatientICD_21_09, in1=rifq2021.outpatient_revenue_09, in2=rifq2021.outpatient_claims_09);
%ercp (out=ercp_outpatientICD_21_10, in1=rifq2021.outpatient_revenue_10, in2=rifq2021.outpatient_claims_10);
%ercp (out=ercp_outpatientICD_21_11, in1=rifq2021.outpatient_revenue_11, in2=rifq2021.outpatient_claims_11);
%ercp (out=ercp_outpatientICD_21_12, in1=rifq2021.outpatient_revenue_12, in2=rifq2021.outpatient_claims_12);

*label variables endo_ so know they come from index procedure--note these are by setting (carrier, in, out);
data ercp_carrier (keep = bene_id endo_:  LINE_PLACE_OF_SRVC_CD);
set 
ercp_carrier_:;
endo_clm_id=clm_id;
endo_DT=clm_thru_dt; format endo_dt date9.;
endo_age=(endo_dt-dob_dt)/365.25;
endo_bene_race_cd=bene_race_cd ;
endo_bene_state_cd=bene_state_cd; 
endo_bene_cnty_cd =bene_cnty_cd ;
endo_gndr_cd=gndr_cd;
endo_year=year(clm_thru_dt);
endo_org_npi_num=org_npi_num;
endo_prf_physn_npi=prf_physn_npi;
endo_prvdr_spclty=prvdr_spclty;
endo_hcpcs_cd=hcpcs_cd;
endo_NCH_CLM_TYPE_CD=NCH_CLM_TYPE_CD;
endo_icd_dgns_cd1=icd_dgns_cd1;
endo_CLM_PMT_AMT=CLM_PMT_AMT;
endo_LINE_SBMTD_CHRG_AMT=LINE_SBMTD_CHRG_AMT;
*label if had an infection on index procedure, cancer and panc;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
			*Any type of cancer at procedure;
		if SUBSTR(dx(i),1,1) in('C') then do; endo_cancer_at_proc=1; end;
		*Disorders of gallbladder, biliary tract and pancreas;
		if SUBSTR(dx(i),1,3) in('K80', 'K81','K82','K83','K84','K85','K86','K87') then do; 
			endo_PANC_at_proc=1; end;
		if SUBSTR(dx(i),1,5) in('K9189') then do; endo_PEP_at_proc=1; end;
		if SUBSTR(dx(i),1,1) in('A','B') then do; endo_infect_at_proc=1; end;
if substr(dx(i),1,3) 
in( '001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', 
	'013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', 
	'025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', 
	'037', '038', '039', '040', '041', '042', '043', '044', '045', '046', '047', '048', 
	'049', '050', '051', '052', '053', '054', '055', '056', '057', '058', '059', '060', 
	'061', '062', '063', '064', '065', '066', '067', '068', '069', '070', '071', '072', 
	'073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', '084', 
	'085', '086', '087', '088', '089', '090', '091', '092', '093', '094', '095', '096', 
	'097', '098', '099', '100', '101', '102', '103', '104', '105', '106', '107', '108', 
	'109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', 
	'121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', 
	'133', '134', '135', '136', '137', '138', '139', 
	'320', '321', '323', 'G00', 'G01', 'G02', 'G04', 'G05',
	'460', '461', '462', '463', '464', '465', '466',
	'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
	'J09', 'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
	'480', '481', '482', '483', '484', '485', '486', '487', '488', 
	'567', 'K67', 
	'V09', 'Z16') then do; endo_infect_at_proc=1; end;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3) in('K50','K51') then endo_ibd=1; end;
if endo_infect_at_proc=. then endo_infect_at_proc=0;
*limit to gastroenterology or ASCs;
*if endo_prvdr_spclty notin('02','10','11','49') then delete; *keep general surgeon, gastroenterologist, IM, ASC only;
*limit to non-DME by deleting dme;
if nch_clm_type_cd in('72', '81', '82') then delete;
*set vars with missing to 0;
if endo_infect_at_proc=. then  endo_infect_at_proc=0;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if endo_PANC_at_proc=. then endo_PANC_at_proc=0;
if endo_ibd_at_proc=. then endo_ibd_at_proc=0;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
endo_setting='CAR';
run; 
*make table that identifies if inpatient proc from pos code;
data ercp_car_inp_pos (keep = bene_id endo_dt inp_pos); set ercp_carrier;
where LINE_PLACE_OF_SRVC_CD = '21';
inp_pos=1;
label inp_pos='indicates that ercp was inpatient from carrier place of service';
run;
proc sort data=ercp_car_inp_pos nodupkey; by bene_id endo_dt; run;

proc sort data=ercp_carrier nodupkey; by bene_id endo_dt endo_hcpcs_cd; run; 
proc freq data=ercp_carrier order=freq; 
table endo_NCH_CLM_TYPE_CD  endo_prvdr_spclty  
endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_year endo_hcpcs_cd 
endo_icd_dgns_cd1 endo_setting; run;
*tranpose so 1 line per procedure so can identify all procedures performed on this day;
proc sort data=ercp_carrier; by bene_id endo_dt; run;
proc transpose data=ercp_carrier out=ercp_carrier2 (drop = _name_) prefix=endo_hcpcs_cd;
by bene_id endo_dt;
var endo_hcpcs_cd;
run;

proc sort data=ercp_carrier nodupkey out=ercp_carrier_nodup; by bene_id endo_dt; run;
data ercp_carrier3;
merge 
ercp_carrier_nodup (in=a drop =  endo_hcpcs_cd)
ercp_car_inp_pos
ercp_carrier2 (in=b);
by bene_id endo_dt;
if b;
array hcpcs(5) endo_hcpcs_cd1 - endo_hcpcs_cd5;
	do i=1 to 5;
	*if have disposable on any hcpcs of claim then label disposable;
	if hcpcs(i) = 'C1748' then endo_C1748=1; 
end;
if endo_C1748=. then endo_C1748=0;
if inp_pos=. then inp_pos=0;
run;
proc freq data=ercp_carrier3 order=freq; 
table endo_NCH_CLM_TYPE_CD  inp_pos endo_C1748 endo_prvdr_spclty  
endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_year endo_hcpcs_cd1 
endo_icd_dgns_cd1 endo_setting; run;

*link to get ed visits;
%macro ed(out=, source= );
proc sql;
create table &out (compress=yes) as
select a.bene_id, a.endo_dt, a.endo_clm_id, b.betos_cd, b.hcpcs_cd
from 
ercp_carrier3 a, 
&source b 
where a.bene_id=b.bene_id  
and
a.endo_dt=b.clm_thru_dt /*carrier based on date, inp and outp based on clm match*/
and 
	/*b.betos_cd='M3' none had ED betos code in jul2020-feb2021 or jul2019 so not using
	OR  */
	b.hcpcs_cd in('99281', '99282', '99283', '99284','99285');*
b.rev_cntr in('0450','0451','0452','0453','0454','0455','0456','0457','0458','0459','0981')
;
quit; 
%mend;

%ed(out=ed_carrier_15_01, source=rif2015.bcarrier_line_01 );
%ed(out=ed_carrier_15_02, source=rif2015.bcarrier_line_02 );
%ed(out=ed_carrier_15_03, source=rif2015.bcarrier_line_03 );
%ed(out=ed_carrier_15_04, source=rif2015.bcarrier_line_04 );
%ed(out=ed_carrier_15_05, source=rif2015.bcarrier_line_05 );
%ed(out=ed_carrier_15_06, source=rif2015.bcarrier_line_06 );
%ed(out=ed_carrier_15_07, source=rif2015.bcarrier_line_07 );
%ed(out=ed_carrier_15_08, source=rif2015.bcarrier_line_08 );
%ed(out=ed_carrier_15_09, source=rif2015.bcarrier_line_09 );
%ed(out=ed_carrier_15_10, source=rif2015.bcarrier_line_10 );
%ed(out=ed_carrier_15_11, source=rif2015.bcarrier_line_11 );
%ed(out=ed_carrier_15_12, source=rif2015.bcarrier_line_12 );

%ed(out=ed_carrier_16_01, source=rif2016.bcarrier_line_01 );
%ed(out=ed_carrier_16_02, source=rif2016.bcarrier_line_02 );
%ed(out=ed_carrier_16_03, source=rif2016.bcarrier_line_03 );
%ed(out=ed_carrier_16_04, source=rif2016.bcarrier_line_04 );
%ed(out=ed_carrier_16_05, source=rif2016.bcarrier_line_05 );
%ed(out=ed_carrier_16_06, source=rif2016.bcarrier_line_06 );
%ed(out=ed_carrier_16_07, source=rif2016.bcarrier_line_07 );
%ed(out=ed_carrier_16_08, source=rif2016.bcarrier_line_08 );
%ed(out=ed_carrier_16_09, source=rif2016.bcarrier_line_09 );
%ed(out=ed_carrier_16_10, source=rif2016.bcarrier_line_10 );
%ed(out=ed_carrier_16_11, source=rif2016.bcarrier_line_11 );
%ed(out=ed_carrier_16_12, source=rif2016.bcarrier_line_12 );

%ed(out=ed_carrier_17_01, source=rif2017.bcarrier_line_01 );
%ed(out=ed_carrier_17_02, source=rif2017.bcarrier_line_02 );
%ed(out=ed_carrier_17_03, source=rif2017.bcarrier_line_03 );
%ed(out=ed_carrier_17_04, source=rif2017.bcarrier_line_04 );
%ed(out=ed_carrier_17_05, source=rif2017.bcarrier_line_05 );
%ed(out=ed_carrier_17_06, source=rif2017.bcarrier_line_06 );
%ed(out=ed_carrier_17_07, source=rif2017.bcarrier_line_07 );
%ed(out=ed_carrier_17_08, source=rif2017.bcarrier_line_08 );
%ed(out=ed_carrier_17_09, source=rif2017.bcarrier_line_09 );
%ed(out=ed_carrier_17_10, source=rif2017.bcarrier_line_10 );
%ed(out=ed_carrier_17_11, source=rif2017.bcarrier_line_11 );
%ed(out=ed_carrier_17_12, source=rif2017.bcarrier_line_12 );

%ed(out=ed_carrier_18_01, source=rifq2018.bcarrier_line_01 );
%ed(out=ed_carrier_18_02, source=rifq2018.bcarrier_line_02 );
%ed(out=ed_carrier_18_03, source=rifq2018.bcarrier_line_03 );
%ed(out=ed_carrier_18_04, source=rifq2018.bcarrier_line_04 );
%ed(out=ed_carrier_18_05, source=rifq2018.bcarrier_line_05 );
%ed(out=ed_carrier_18_06, source=rifq2018.bcarrier_line_06 );
%ed(out=ed_carrier_18_07, source=rifq2018.bcarrier_line_07 );
%ed(out=ed_carrier_18_08, source=rifq2018.bcarrier_line_08 );
%ed(out=ed_carrier_18_09, source=rifq2018.bcarrier_line_09 );
%ed(out=ed_carrier_18_10, source=rifq2018.bcarrier_line_10 );
%ed(out=ed_carrier_18_11, source=rifq2018.bcarrier_line_11 );
%ed(out=ed_carrier_18_12, source=rifq2018.bcarrier_line_12 );

%ed(out=ed_carrier_19_01, source=rifq2019.bcarrier_line_01 );
%ed(out=ed_carrier_19_02, source=rifq2019.bcarrier_line_02 );
%ed(out=ed_carrier_19_03, source=rifq2019.bcarrier_line_03 );
%ed(out=ed_carrier_19_04, source=rifq2019.bcarrier_line_04 );
%ed(out=ed_carrier_19_05, source=rifq2019.bcarrier_line_05 );
%ed(out=ed_carrier_19_06, source=rifq2019.bcarrier_line_06 );
%ed(out=ed_carrier_19_07, source=rifq2019.bcarrier_line_07 );
%ed(out=ed_carrier_19_08, source=rifq2019.bcarrier_line_08 );
%ed(out=ed_carrier_19_09, source=rifq2019.bcarrier_line_09 );
%ed(out=ed_carrier_19_10, source=rifq2019.bcarrier_line_10 );
%ed(out=ed_carrier_19_11, source=rifq2019.bcarrier_line_11 );
%ed(out=ed_carrier_19_12, source=rifq2019.bcarrier_line_12 );

%ed(out=ed_carrier_20_01, source=rifq2020.bcarrier_line_01 );
%ed(out=ed_carrier_20_02, source=rifq2020.bcarrier_line_02 );
%ed(out=ed_carrier_20_03, source=rifq2020.bcarrier_line_03 );
%ed(out=ed_carrier_20_04, source=rifq2020.bcarrier_line_04 );
%ed(out=ed_carrier_20_05, source=rifq2020.bcarrier_line_05 );
%ed(out=ed_carrier_20_06, source=rifq2020.bcarrier_line_06 );
%ed(out=ed_carrier_20_07, source=rifq2020.bcarrier_line_07 );
%ed(out=ed_carrier_20_08, source=rifq2020.bcarrier_line_08 );
%ed(out=ed_carrier_20_09, source=rifq2020.bcarrier_line_09 );
%ed(out=ed_carrier_20_10, source=rifq2020.bcarrier_line_10 );
%ed(out=ed_carrier_20_11, source=rifq2020.bcarrier_line_11 );
%ed(out=ed_carrier_20_12, source=rifq2020.bcarrier_line_12 );

%ed(out=ed_carrier_21_01, source=rifq2021.bcarrier_line_01 );
%ed(out=ed_carrier_21_02, source=rifq2021.bcarrier_line_02 );
%ed(out=ed_carrier_21_03, source=rifq2021.bcarrier_line_03 );
%ed(out=ed_carrier_21_04, source=rifq2021.bcarrier_line_04 );
%ed(out=ed_carrier_21_05, source=rifq2021.bcarrier_line_05 );
%ed(out=ed_carrier_21_06, source=rifq2021.bcarrier_line_06 );
%ed(out=ed_carrier_21_07, source=rifq2021.bcarrier_line_07 );
%ed(out=ed_carrier_21_08, source=rifq2021.bcarrier_line_08 );
%ed(out=ed_carrier_21_09, source=rifq2021.bcarrier_line_09 );
%ed(out=ed_carrier_21_10, source=rifq2021.bcarrier_line_10 );
%ed(out=ed_carrier_21_11, source=rifq2021.bcarrier_line_11 );
%ed(out=ed_carrier_21_12, source=rifq2021.bcarrier_line_12 );

data ed_carrier (keep = bene_id endo_dt ed);
set ed_carrier_:	;
ed=1;
label = 'indicator that claim occurred in emergency room/had emergency room component';
run;
proc sort data=ed_carrier nodupkey; by bene_id endo_dt; run;

data ercp_carrier4; 
merge ed_carrier ercp_carrier3; 
by bene_id endo_dt;
if ed=. then ed=0;
*if ed=1 then elective=0; *else elective=1;
run;


*make dataset of inpatient procedures;
data ercp_inp (keep = bene_id endo_:);
set ercp_inpatient: ercp_inpatientICD: ;
endo_clm_id=clm_id;
endo_DT=clm_thru_dt; format endo_dt date9.;
endo_age=(endo_dt-dob_dt)/365.25;
endo_bene_race_cd=bene_race_cd ;
endo_bene_state_cd=bene_state_cd; 
endo_bene_cnty_cd =bene_cnty_cd ;
endo_gndr_cd=gndr_cd;
endo_year=year(clm_thru_dt);
endo_prvdr_num=prvdr_num;
endo_OP_PHYSN_NPI=OP_PHYSN_NPI;
endo_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
endo_NCH_CLM_TYPE_CD=NCH_CLM_TYPE_CD;
endo_CLM_IP_ADMSN_TYPE_CD=CLM_IP_ADMSN_TYPE_CD;
endo_hcpcs_cd=hcpcs_cd;
endo_icd_dgns_cd1=icd_dgns_cd1;
endo_icd_prcdr_cd1=icd_prcdr_cd1;
endo_CLM_PMT_AMT=CLM_PMT_AMT;
endo_LINE_SBMTD_CHRG_AMT=LINE_SBMTD_CHRG_AMT;
if hcpcs_cd='C1748' then endo_C1748=1;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
	*if had an infection on index procedure BASED ON DX CODE & POA then delete;
if SUBSTR(dx(i),1,1) in('A','B') then do; endo_infect_at_proc=11; poa_num=i; end;
if substr(dx(i),1,3) 
in( '001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', 
	'013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', 
	'025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', 
	'037', '038', '039', '040', '041', '042', '043', '044', '045', '046', '047', '048', 
	'049', '050', '051', '052', '053', '054', '055', '056', '057', '058', '059', '060', 
	'061', '062', '063', '064', '065', '066', '067', '068', '069', '070', '071', '072', 
	'073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', '084', 
	'085', '086', '087', '088', '089', '090', '091', '092', '093', '094', '095', '096', 
	'097', '098', '099', '100', '101', '102', '103', '104', '105', '106', '107', '108', 
	'109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', 
	'121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', 
	'133', '134', '135', '136', '137', '138', '139', 
	'320', '321', '323', 'G00', 'G01', 'G02', 'G04', 'G05',
	'460', '461', '462', '463', '464', '465', '466',
	'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
	'J09', 'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
	'480', '481', '482', '483', '484', '485', '486', '487', '488', 
	'567', 'K67', 
	'V09', 'Z16') then do; endo_infect_at_proc=11; poa_num=i; end;
			*Any type of cancer at procedure;
		if SUBSTR(dx(i),1,1) in('C') then do; endo_cancer_at_proc=1; end;
		*Disorders of gallbladder, biliary tract and pancreas;
		if SUBSTR(dx(i),1,3) in('K80', 'K81','K82','K83','K84','K85','K86','K87') then do; 
			endo_PANC_at_proc=1; end;
			if SUBSTR(dx(i),1,5) in('K9189') then do; endo_PEP_at_proc=1; end; *POST ERCP PANCREATITIS;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3) in('K50','K51') then endo_ibd=1; 
end;
	array poa(25) CLM_POA_IND_SW1-CLM_POA_IND_SW25;
		do k = 1 to 25;
			if endo_infect_at_proc=11 and poa(k) ='Y' and poa_num=k then do;
				endo_infect_at_proc=1; 
			end;
	end;
*limit to gastroenterology or ASCs;
*if endo_prvdr_spclty notin('02','10','11','49') then delete; *keep general surgeon, gastroenterologist, IM, ASC only;
*limit to non-DME by deleting dme;
if nch_clm_type_cd in('72', '81', '82') then delete;
*set missing values to 0;
if endo_infect_at_proc=11 then endo_infect_at_proc=.;
if endo_infect_at_proc=. then endo_infect_at_proc=0;
*create eletive indicator;
if CLM_IP_ADMSN_TYPE_CD = '3' then endo_elective=1; else endo_elective=0;
*if CLM_IP_ADMSN_TYPE_CD ne '3' then delete; *elective is 3;
if endo_infect_at_proc=. then  endo_infect_at_proc=0;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if endo_PANC_at_proc=. then endo_PANC_at_proc=0;
if endo_ibd_at_proc=. then endo_ibd_at_proc=0;
if endo_C1748=. then endo_C1748=0;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
endo_setting='INP';
run;
*look at demogs to compare with state data;
proc freq data=ercp_inp; where endo_year=2017;
table endo_CLM_IP_ADMSN_TYPE_CD endo_NCH_CLM_TYPE_CD endo_C1748 
endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_year endo_hcpcs_cd 
endo_icd_dgns_cd1 endo_setting; run;

proc sort data=ercp_inp nodupkey; by bene_id endo_dt; run; 
proc freq data=ercp_inp order=freq; table endo_NCH_CLM_TYPE_CD endo_C1748;* endo_icd_prcdr_cd1; run;

*make ED indicator;
%macro ed(out=, source= );
proc sql;
create table &out (compress=yes) as
select a.bene_id, a.endo_dt, a.endo_clm_id, b.rev_cntr
from 
ercp_inp a, 
&source b 
where a.bene_id=b.bene_id  
and
a.endo_clm_id=b.clm_id
and 
b.rev_cntr in('0450','0451','0452','0453','0454','0455','0456','0457','0458','0459','0981')
;
quit; 
%mend;

%ed(out=ed_inpatient_15_01, source=rif2015.inpatient_revenue_01 );
%ed(out=ed_inpatient_15_02, source=rif2015.inpatient_revenue_02 );
%ed(out=ed_inpatient_15_03, source=rif2015.inpatient_revenue_03 );
%ed(out=ed_inpatient_15_04, source=rif2015.inpatient_revenue_04 );
%ed(out=ed_inpatient_15_05, source=rif2015.inpatient_revenue_05 );
%ed(out=ed_inpatient_15_06, source=rif2015.inpatient_revenue_06 );
%ed(out=ed_inpatient_15_07, source=rif2015.inpatient_revenue_07 );
%ed(out=ed_inpatient_15_08, source=rif2015.inpatient_revenue_08 );
%ed(out=ed_inpatient_15_09, source=rif2015.inpatient_revenue_09 );
%ed(out=ed_inpatient_15_10, source=rif2015.inpatient_revenue_10 );
%ed(out=ed_inpatient_15_11, source=rif2015.inpatient_revenue_11 );
%ed(out=ed_inpatient_15_12, source=rif2015.inpatient_revenue_12 );

%ed(out=ed_inpatient_16_01, source=rif2016.inpatient_revenue_01 );
%ed(out=ed_inpatient_16_02, source=rif2016.inpatient_revenue_02 );
%ed(out=ed_inpatient_16_03, source=rif2016.inpatient_revenue_03 );
%ed(out=ed_inpatient_16_04, source=rif2016.inpatient_revenue_04 );
%ed(out=ed_inpatient_16_05, source=rif2016.inpatient_revenue_05 );
%ed(out=ed_inpatient_16_06, source=rif2016.inpatient_revenue_06 );
%ed(out=ed_inpatient_16_07, source=rif2016.inpatient_revenue_07 );
%ed(out=ed_inpatient_16_08, source=rif2016.inpatient_revenue_08 );
%ed(out=ed_inpatient_16_09, source=rif2016.inpatient_revenue_09 );
%ed(out=ed_inpatient_16_10, source=rif2016.inpatient_revenue_10 );
%ed(out=ed_inpatient_16_11, source=rif2016.inpatient_revenue_11 );
%ed(out=ed_inpatient_16_12, source=rif2016.inpatient_revenue_12 );

%ed(out=ed_inpatient_17_01, source=rif2017.inpatient_revenue_01 );
%ed(out=ed_inpatient_17_02, source=rif2017.inpatient_revenue_02 );
%ed(out=ed_inpatient_17_03, source=rif2017.inpatient_revenue_03 );
%ed(out=ed_inpatient_17_04, source=rif2017.inpatient_revenue_04 );
%ed(out=ed_inpatient_17_05, source=rif2017.inpatient_revenue_05 );
%ed(out=ed_inpatient_17_06, source=rif2017.inpatient_revenue_06 );
%ed(out=ed_inpatient_17_07, source=rif2017.inpatient_revenue_07 );
%ed(out=ed_inpatient_17_08, source=rif2017.inpatient_revenue_08 );
%ed(out=ed_inpatient_17_09, source=rif2017.inpatient_revenue_09 );
%ed(out=ed_inpatient_17_10, source=rif2017.inpatient_revenue_10 );
%ed(out=ed_inpatient_17_11, source=rif2017.inpatient_revenue_11 );
%ed(out=ed_inpatient_17_12, source=rif2017.inpatient_revenue_12 );

%ed(out=ed_inpatient_18_01, source=rifq2018.inpatient_revenue_01 );
%ed(out=ed_inpatient_18_02, source=rifq2018.inpatient_revenue_02 );
%ed(out=ed_inpatient_18_03, source=rifq2018.inpatient_revenue_03 );
%ed(out=ed_inpatient_18_04, source=rifq2018.inpatient_revenue_04 );
%ed(out=ed_inpatient_18_05, source=rifq2018.inpatient_revenue_05 );
%ed(out=ed_inpatient_18_06, source=rifq2018.inpatient_revenue_06 );
%ed(out=ed_inpatient_18_07, source=rifq2018.inpatient_revenue_07 );
%ed(out=ed_inpatient_18_08, source=rifq2018.inpatient_revenue_08 );
%ed(out=ed_inpatient_18_09, source=rifq2018.inpatient_revenue_09 );
%ed(out=ed_inpatient_18_10, source=rifq2018.inpatient_revenue_10 );
%ed(out=ed_inpatient_18_11, source=rifq2018.inpatient_revenue_11 );
%ed(out=ed_inpatient_18_12, source=rifq2018.inpatient_revenue_12 );

%ed(out=ed_inpatient_19_01, source=rifq2019.inpatient_revenue_01 );
%ed(out=ed_inpatient_19_02, source=rifq2019.inpatient_revenue_02 );
%ed(out=ed_inpatient_19_03, source=rifq2019.inpatient_revenue_03 );
%ed(out=ed_inpatient_19_04, source=rifq2019.inpatient_revenue_04 );
%ed(out=ed_inpatient_19_05, source=rifq2019.inpatient_revenue_05 );
%ed(out=ed_inpatient_19_06, source=rifq2019.inpatient_revenue_06 );
%ed(out=ed_inpatient_19_07, source=rifq2019.inpatient_revenue_07 );
%ed(out=ed_inpatient_19_08, source=rifq2019.inpatient_revenue_08 );
%ed(out=ed_inpatient_19_09, source=rifq2019.inpatient_revenue_09 );
%ed(out=ed_inpatient_19_10, source=rifq2019.inpatient_revenue_10 );
%ed(out=ed_inpatient_19_11, source=rifq2019.inpatient_revenue_11 );
%ed(out=ed_inpatient_19_12, source=rifq2019.inpatient_revenue_12 );

%ed(out=ed_inpatient_20_01, source=rifq2020.inpatient_revenue_01 );
%ed(out=ed_inpatient_20_02, source=rifq2020.inpatient_revenue_02 );
%ed(out=ed_inpatient_20_03, source=rifq2020.inpatient_revenue_03 );
%ed(out=ed_inpatient_20_04, source=rifq2020.inpatient_revenue_04 );
%ed(out=ed_inpatient_20_05, source=rifq2020.inpatient_revenue_05 );
%ed(out=ed_inpatient_20_06, source=rifq2020.inpatient_revenue_06 );
%ed(out=ed_inpatient_20_07, source=rifq2020.inpatient_revenue_07 );
%ed(out=ed_inpatient_20_08, source=rifq2020.inpatient_revenue_08 );
%ed(out=ed_inpatient_20_09, source=rifq2020.inpatient_revenue_09 );
%ed(out=ed_inpatient_20_10, source=rifq2020.inpatient_revenue_10 );
%ed(out=ed_inpatient_20_11, source=rifq2020.inpatient_revenue_11 );
%ed(out=ed_inpatient_20_12, source=rifq2020.inpatient_revenue_12 );

%ed(out=ed_inpatient_21_01, source=rifq2021.inpatient_revenue_01 );
%ed(out=ed_inpatient_21_02, source=rifq2021.inpatient_revenue_02 );
%ed(out=ed_inpatient_21_03, source=rifq2021.inpatient_revenue_03 );
%ed(out=ed_inpatient_21_04, source=rifq2021.inpatient_revenue_04 );
%ed(out=ed_inpatient_21_05, source=rifq2021.inpatient_revenue_05 );
%ed(out=ed_inpatient_21_06, source=rifq2021.inpatient_revenue_06 );
%ed(out=ed_inpatient_21_07, source=rifq2021.inpatient_revenue_07 );
%ed(out=ed_inpatient_21_08, source=rifq2021.inpatient_revenue_08 );
%ed(out=ed_inpatient_21_09, source=rifq2021.inpatient_revenue_09 );
%ed(out=ed_inpatient_21_10, source=rifq2021.inpatient_revenue_10 );
%ed(out=ed_inpatient_21_11, source=rifq2021.inpatient_revenue_11 );
%ed(out=ed_inpatient_21_12, source=rifq2021.inpatient_revenue_12 );

data ed_inpatient (keep = bene_id endo_dt ed);
set ed_inpatient_:	;
ed=1;
label = 'indicator that claim occurred in emergency room/had emergency room component';
run;
proc sort data=ed_inpatient nodupkey; by bene_id endo_dt; run;

data ercp_inp; 
merge ed_inpatient ercp_inp; 
by bene_id endo_dt;
if ed=. then ed=0;
run;


*make dataset of outpatient procedures;
data ercp_outp (keep = bene_id endo_:);
set ercp_outpatient: ercp_outpatientICD: ;
endo_clm_id=clm_id;
endo_DT=clm_thru_dt; format endo_dt date9.;
endo_age=(endo_dt-dob_dt)/365.25;
endo_bene_race_cd=bene_race_cd ;
endo_bene_state_cd=bene_state_cd; 
endo_bene_cnty_cd =bene_cnty_cd ;
endo_gndr_cd=gndr_cd;
endo_year=year(clm_thru_dt);
endo_prvdr_num=prvdr_num;
endo_OP_PHYSN_NPI=OP_PHYSN_NPI;
endo_hcpcs_cd=hcpcs_cd;
endo_NCH_CLM_TYPE_CD=NCH_CLM_TYPE_CD;
endo_icd_dgns_cd1=icd_dgns_cd1;
endo_icd_prcdr_cd1=icd_prcdr_cd1;
endo_CLM_PMT_AMT=CLM_PMT_AMT;
endo_LINE_SBMTD_CHRG_AMT=LINE_SBMTD_CHRG_AMT;
endo_mac_num=fi_num;
*if had an infection on index procedure then delete;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
	*if had an infection on index procedure BASED ON DX CODE & POA then delete;
if SUBSTR(dx(i),1,1) in('A','B') then do; endo_infect_at_proc=1; end;
if substr(dx(i),1,3) 
in( '001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', 
	'013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', 
	'025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', 
	'037', '038', '039', '040', '041', '042', '043', '044', '045', '046', '047', '048', 
	'049', '050', '051', '052', '053', '054', '055', '056', '057', '058', '059', '060', 
	'061', '062', '063', '064', '065', '066', '067', '068', '069', '070', '071', '072', 
	'073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', '084', 
	'085', '086', '087', '088', '089', '090', '091', '092', '093', '094', '095', '096', 
	'097', '098', '099', '100', '101', '102', '103', '104', '105', '106', '107', '108', 
	'109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', 
	'121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', 
	'133', '134', '135', '136', '137', '138', '139', 
	'320', '321', '323', 'G00', 'G01', 'G02', 'G04', 'G05',
	'460', '461', '462', '463', '464', '465', '466',
	'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
	'J09', 'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
	'480', '481', '482', '483', '484', '485', '486', '487', '488', 
	'567', 'K67', 
	'V09', 'Z16') then do; endo_infect_at_proc=1; end;
			*Any type of cancer at procedure;
		if SUBSTR(dx(i),1,1) in('C') then do; endo_cancer_at_proc=1; end;
		*Disorders of gallbladder, biliary tract and pancreas;
		if SUBSTR(dx(i),1,3) in('K80', 'K81','K82','K83','K84','K85','K86','K87') then do; 
			endo_PANC_at_proc=1; end;
		if SUBSTR(dx(i),1,5) in('K9189') then do; endo_PEP_at_proc=1; end;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3) in('K50','K51') then endo_ibd=1; 
end;
*limit to gastroenterology or ASCs;
*if endo_prvdr_spclty notin('02','10','11','49') then delete; *keep general surgeon, gastroenterologist, IM, ASC only;
*limit to non-DME by deleting dme;
if nch_clm_type_cd in('72', '81', '82') then delete;
*delete those with infection at admission;
*if endo_infect_at_proc=1 then delete;
if endo_infect_at_proc=. then  endo_infect_at_proc=0;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if endo_PANC_at_proc=. then endo_PANC_at_proc=0;
if endo_ibd_at_proc=. then endo_ibd_at_proc=0;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
endo_setting='OUT';
run;

proc freq data=ercp_outp; where endo_year=2017;
table endo_NCH_CLM_TYPE_CD endo_C1748 
endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_year endo_hcpcs_cd 
endo_icd_dgns_cd1 endo_setting endo_PEP_at_proc; run;

proc sort data=ercp_outp nodupkey; by bene_id endo_dt endo_hcpcs_cd ; run; 
proc freq data=ercp_outp order=freq; table endo_NCH_CLM_TYPE_CD;* endo_C1748;* endo_icd_prcdr_cd1; run;

*tranpose so 1 line per procedure so can identify all procedures performed on this day;
proc sort data=ercp_outp; by bene_id endo_dt; run;
proc transpose data=ercp_outp out=ercp_outp2 (drop = _name_) prefix=endo_hcpcs_cd;
by bene_id endo_dt;
var endo_hcpcs_cd;
run;

proc sort data=ercp_outp nodupkey out=ercp_outp_nodup; by bene_id endo_dt; run;
data ercp_outp;
merge 
ercp_outp_nodup (in=a drop =  endo_hcpcs_cd)
ercp_outp2 (in=b);
by bene_id endo_dt;
if b;
array hcpcs(5) endo_hcpcs_cd1 - endo_hcpcs_cd5;
	do i=1 to 5;
	*if have disposable on any hcpcs of claim then label disposable;
	if hcpcs(i) = 'C1748' then endo_C1748=1; 
end;
if endo_C1748=. then endo_C1748=0;
run;

proc freq data=ercp_outp order=freq; table endo_NCH_CLM_TYPE_CD endo_C1748;* endo_icd_prcdr_cd1; run;
*make ED indicator;
%macro ed(out=, source= );
proc sql;
create table &out (compress=yes) as
select a.bene_id, a.endo_dt, a.endo_clm_id, b.rev_cntr
from 
ercp_outp a, 
&source b 
where a.bene_id=b.bene_id  
and
a.endo_clm_id=b.clm_id
and 
b.rev_cntr in('0450','0451','0452','0453','0454','0455','0456','0457','0458','0459','0981')
;
quit; 
%mend;

%ed(out=ed_outpatient_15_01, source=rif2015.outpatient_revenue_01 );
%ed(out=ed_outpatient_15_02, source=rif2015.outpatient_revenue_02 );
%ed(out=ed_outpatient_15_03, source=rif2015.outpatient_revenue_03 );
%ed(out=ed_outpatient_15_04, source=rif2015.outpatient_revenue_04 );
%ed(out=ed_outpatient_15_05, source=rif2015.outpatient_revenue_05 );
%ed(out=ed_outpatient_15_06, source=rif2015.outpatient_revenue_06 );
%ed(out=ed_outpatient_15_07, source=rif2015.outpatient_revenue_07 );
%ed(out=ed_outpatient_15_08, source=rif2015.outpatient_revenue_08 );
%ed(out=ed_outpatient_15_09, source=rif2015.outpatient_revenue_09 );
%ed(out=ed_outpatient_15_10, source=rif2015.outpatient_revenue_10 );
%ed(out=ed_outpatient_15_11, source=rif2015.outpatient_revenue_11 );
%ed(out=ed_outpatient_15_12, source=rif2015.outpatient_revenue_12 );

%ed(out=ed_outpatient_16_01, source=rif2016.outpatient_revenue_01 );
%ed(out=ed_outpatient_16_02, source=rif2016.outpatient_revenue_02 );
%ed(out=ed_outpatient_16_03, source=rif2016.outpatient_revenue_03 );
%ed(out=ed_outpatient_16_04, source=rif2016.outpatient_revenue_04 );
%ed(out=ed_outpatient_16_05, source=rif2016.outpatient_revenue_05 );
%ed(out=ed_outpatient_16_06, source=rif2016.outpatient_revenue_06 );
%ed(out=ed_outpatient_16_07, source=rif2016.outpatient_revenue_07 );
%ed(out=ed_outpatient_16_08, source=rif2016.outpatient_revenue_08 );
%ed(out=ed_outpatient_16_09, source=rif2016.outpatient_revenue_09 );
%ed(out=ed_outpatient_16_10, source=rif2016.outpatient_revenue_10 );
%ed(out=ed_outpatient_16_11, source=rif2016.outpatient_revenue_11 );
%ed(out=ed_outpatient_16_12, source=rif2016.outpatient_revenue_12 );

%ed(out=ed_outpatient_17_01, source=rif2017.outpatient_revenue_01 );
%ed(out=ed_outpatient_17_02, source=rif2017.outpatient_revenue_02 );
%ed(out=ed_outpatient_17_03, source=rif2017.outpatient_revenue_03 );
%ed(out=ed_outpatient_17_04, source=rif2017.outpatient_revenue_04 );
%ed(out=ed_outpatient_17_05, source=rif2017.outpatient_revenue_05 );
%ed(out=ed_outpatient_17_06, source=rif2017.outpatient_revenue_06 );
%ed(out=ed_outpatient_17_07, source=rif2017.outpatient_revenue_07 );
%ed(out=ed_outpatient_17_08, source=rif2017.outpatient_revenue_08 );
%ed(out=ed_outpatient_17_09, source=rif2017.outpatient_revenue_09 );
%ed(out=ed_outpatient_17_10, source=rif2017.outpatient_revenue_10 );
%ed(out=ed_outpatient_17_11, source=rif2017.outpatient_revenue_11 );
%ed(out=ed_outpatient_17_12, source=rif2017.outpatient_revenue_12 );

%ed(out=ed_outpatient_18_01, source=rifq2018.outpatient_revenue_01 );
%ed(out=ed_outpatient_18_02, source=rifq2018.outpatient_revenue_02 );
%ed(out=ed_outpatient_18_03, source=rifq2018.outpatient_revenue_03 );
%ed(out=ed_outpatient_18_04, source=rifq2018.outpatient_revenue_04 );
%ed(out=ed_outpatient_18_05, source=rifq2018.outpatient_revenue_05 );
%ed(out=ed_outpatient_18_06, source=rifq2018.outpatient_revenue_06 );
%ed(out=ed_outpatient_18_07, source=rifq2018.outpatient_revenue_07 );
%ed(out=ed_outpatient_18_08, source=rifq2018.outpatient_revenue_08 );
%ed(out=ed_outpatient_18_09, source=rifq2018.outpatient_revenue_09 );
%ed(out=ed_outpatient_18_10, source=rifq2018.outpatient_revenue_10 );
%ed(out=ed_outpatient_18_11, source=rifq2018.outpatient_revenue_11 );
%ed(out=ed_outpatient_18_12, source=rifq2018.outpatient_revenue_12 );

%ed(out=ed_outpatient_19_01, source=rifq2019.outpatient_revenue_01 );
%ed(out=ed_outpatient_19_02, source=rifq2019.outpatient_revenue_02 );
%ed(out=ed_outpatient_19_03, source=rifq2019.outpatient_revenue_03 );
%ed(out=ed_outpatient_19_04, source=rifq2019.outpatient_revenue_04 );
%ed(out=ed_outpatient_19_05, source=rifq2019.outpatient_revenue_05 );
%ed(out=ed_outpatient_19_06, source=rifq2019.outpatient_revenue_06 );
%ed(out=ed_outpatient_19_07, source=rifq2019.outpatient_revenue_07 );
%ed(out=ed_outpatient_19_08, source=rifq2019.outpatient_revenue_08 );
%ed(out=ed_outpatient_19_09, source=rifq2019.outpatient_revenue_09 );
%ed(out=ed_outpatient_19_10, source=rifq2019.outpatient_revenue_10 );
%ed(out=ed_outpatient_19_11, source=rifq2019.outpatient_revenue_11 );
%ed(out=ed_outpatient_19_12, source=rifq2019.outpatient_revenue_12 );

%ed(out=ed_outpatient_20_01, source=rifq2020.outpatient_revenue_01 );
%ed(out=ed_outpatient_20_02, source=rifq2020.outpatient_revenue_02 );
%ed(out=ed_outpatient_20_03, source=rifq2020.outpatient_revenue_03 );
%ed(out=ed_outpatient_20_04, source=rifq2020.outpatient_revenue_04 );
%ed(out=ed_outpatient_20_05, source=rifq2020.outpatient_revenue_05 );
%ed(out=ed_outpatient_20_06, source=rifq2020.outpatient_revenue_06 );
%ed(out=ed_outpatient_20_07, source=rifq2020.outpatient_revenue_07 );
%ed(out=ed_outpatient_20_08, source=rifq2020.outpatient_revenue_08 );
%ed(out=ed_outpatient_20_09, source=rifq2020.outpatient_revenue_09 );
%ed(out=ed_outpatient_20_10, source=rifq2020.outpatient_revenue_10 );
%ed(out=ed_outpatient_20_11, source=rifq2020.outpatient_revenue_11 );
%ed(out=ed_outpatient_20_12, source=rifq2020.outpatient_revenue_12 );

%ed(out=ed_outpatient_21_01, source=rifq2021.outpatient_revenue_01 );
%ed(out=ed_outpatient_21_02, source=rifq2021.outpatient_revenue_02 );
%ed(out=ed_outpatient_21_03, source=rifq2021.outpatient_revenue_03 );
%ed(out=ed_outpatient_21_04, source=rifq2021.outpatient_revenue_04 );
%ed(out=ed_outpatient_21_05, source=rifq2021.outpatient_revenue_05 );
%ed(out=ed_outpatient_21_06, source=rifq2021.outpatient_revenue_06 );
%ed(out=ed_outpatient_21_07, source=rifq2021.outpatient_revenue_07 );
%ed(out=ed_outpatient_21_08, source=rifq2021.outpatient_revenue_08 );
%ed(out=ed_outpatient_21_09, source=rifq2021.outpatient_revenue_09 );
%ed(out=ed_outpatient_21_10, source=rifq2021.outpatient_revenue_10 );
%ed(out=ed_outpatient_21_11, source=rifq2021.outpatient_revenue_11 );
%ed(out=ed_outpatient_21_12, source=rifq2021.outpatient_revenue_12 );

data ed_outpatient (keep = bene_id endo_dt ed);
set ed_outpatient_:	;
ed=1;
label = 'indicator that claim occurred in emergency room/had emergency room component';
run;
proc sort data=ed_outpatient nodupkey; by bene_id endo_dt; run;

data ercp_outp; 
merge ed_outpatient ercp_outp; 
by bene_id endo_dt;
if ed=. then ed=0;
run;


*create dataset of carrier, inpatient and outpatient settings in 1;
data endo_ercp;
set
 ercp_inp ercp_outp ercp_carrier4 ;  *list carrier last so it's last to be kept with nodupkey;
 if endo_setting='INP' or inp_pos=1 then inpatient=1;
 else inpatient=0;
run;
proc sort data=endo_ercp nodupkey; by bene_id endo_dt; run;*this sort prioritizes inpatient over outpatient over carrier;
proc freq data= endo_ercp; 
table endo_setting inp_pos inpatient endo_infect_at_proc endo_setting*endo_infect_at_proc endo_PEP_at_proc; run;

*save in permlib so can come back later;
%let permlib=pl052399;
data &permlib..ercp_inp; set ercp_inp;
data &permlib..ercp_outp; set ercp_outp;
data &permlib..ercp_carrier4; set ercp_carrier4;
data &permlib..endo_ercp; set endo_ercp; 
run;
  

*merge to hospitalizations & hospitalizations for infection;


*admission outcomes;
*identify all inpatient dates after index date by linking final cohort to inpatient file again;
*add prefix for readmission info after initially keeping all variables;
%macro inpatient(source=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select a.bene_id, a.endo_dt, a.endo_setting, b.*
from 
endo_ercp a, 
&source b 
where a.bene_id=b.bene_id  
and (a.endo_dt-30)<=b.CLM_ADMSN_DT<=(a.endo_dt+365) /*keep all admissions 30 days before to 1 year after*/
;
quit; 
%mend;
%inpatient(source=rif2015.inpatient_claims_01, include_cohort=endo_outcome_2015_1);
%inpatient(source=rif2015.inpatient_claims_02, include_cohort=endo_outcome_2015_2);
%inpatient(source=rif2015.inpatient_claims_03, include_cohort=endo_outcome_2015_3);
%inpatient(source=rif2015.inpatient_claims_04, include_cohort=endo_outcome_2015_4);
%inpatient(source=rif2015.inpatient_claims_05, include_cohort=endo_outcome_2015_5);
%inpatient(source=rif2015.inpatient_claims_06, include_cohort=endo_outcome_2015_6);
%inpatient(source=rif2015.inpatient_claims_07, include_cohort=endo_outcome_2015_7);
%inpatient(source=rif2015.inpatient_claims_08, include_cohort=endo_outcome_2015_8);
%inpatient(source=rif2015.inpatient_claims_09, include_cohort=endo_outcome_2015_9);
%inpatient(source=rif2015.inpatient_claims_10, include_cohort=endo_outcome_2015_10);
%inpatient(source=rif2015.inpatient_claims_11, include_cohort=endo_outcome_2015_11);
%inpatient(source=rif2015.inpatient_claims_12, include_cohort=endo_outcome_2015_12);

%inpatient(source=rif2016.inpatient_claims_01, include_cohort=endo_outcome_2016_1);
%inpatient(source=rif2016.inpatient_claims_02, include_cohort=endo_outcome_2016_2);
%inpatient(source=rif2016.inpatient_claims_03, include_cohort=endo_outcome_2016_3);
%inpatient(source=rif2016.inpatient_claims_04, include_cohort=endo_outcome_2016_4);
%inpatient(source=rif2016.inpatient_claims_05, include_cohort=endo_outcome_2016_5);
%inpatient(source=rif2016.inpatient_claims_06, include_cohort=endo_outcome_2016_6);
%inpatient(source=rif2016.inpatient_claims_07, include_cohort=endo_outcome_2016_7);
%inpatient(source=rif2016.inpatient_claims_08, include_cohort=endo_outcome_2016_8);
%inpatient(source=rif2016.inpatient_claims_09, include_cohort=endo_outcome_2016_9);
%inpatient(source=rif2016.inpatient_claims_10, include_cohort=endo_outcome_2016_10);
%inpatient(source=rif2016.inpatient_claims_11, include_cohort=endo_outcome_2016_11);
%inpatient(source=rif2016.inpatient_claims_12, include_cohort=endo_outcome_2016_12);

%inpatient(source=rif2017.inpatient_claims_01, include_cohort=endo_outcome_2017_1);
%inpatient(source=rif2017.inpatient_claims_02, include_cohort=endo_outcome_2017_2);
%inpatient(source=rif2017.inpatient_claims_03, include_cohort=endo_outcome_2017_3);
%inpatient(source=rif2017.inpatient_claims_04, include_cohort=endo_outcome_2017_4);
%inpatient(source=rif2017.inpatient_claims_05, include_cohort=endo_outcome_2017_5);
%inpatient(source=rif2017.inpatient_claims_06, include_cohort=endo_outcome_2017_6);
%inpatient(source=rif2017.inpatient_claims_07, include_cohort=endo_outcome_2017_7);
%inpatient(source=rif2017.inpatient_claims_08, include_cohort=endo_outcome_2017_8);
%inpatient(source=rif2017.inpatient_claims_09, include_cohort=endo_outcome_2017_9);
%inpatient(source=rif2017.inpatient_claims_10, include_cohort=endo_outcome_2017_10);
%inpatient(source=rif2017.inpatient_claims_11, include_cohort=endo_outcome_2017_11);
%inpatient(source=rif2017.inpatient_claims_12, include_cohort=endo_outcome_2017_12);

%inpatient(source=rifq2018.inpatient_claims_01, include_cohort=endo_outcome_2018_1);
%inpatient(source=rifq2018.inpatient_claims_02, include_cohort=endo_outcome_2018_2);
%inpatient(source=rifq2018.inpatient_claims_03, include_cohort=endo_outcome_2018_3);
%inpatient(source=rifq2018.inpatient_claims_04, include_cohort=endo_outcome_2018_4);
%inpatient(source=rifq2018.inpatient_claims_05, include_cohort=endo_outcome_2018_5);
%inpatient(source=rifq2018.inpatient_claims_06, include_cohort=endo_outcome_2018_6);
%inpatient(source=rifq2018.inpatient_claims_07, include_cohort=endo_outcome_2018_7);
%inpatient(source=rifq2018.inpatient_claims_08, include_cohort=endo_outcome_2018_8);
%inpatient(source=rifq2018.inpatient_claims_09, include_cohort=endo_outcome_2018_9);
%inpatient(source=rifq2018.inpatient_claims_10, include_cohort=endo_outcome_2018_10);
%inpatient(source=rifq2018.inpatient_claims_11, include_cohort=endo_outcome_2018_11);
%inpatient(source=rifq2018.inpatient_claims_12, include_cohort=endo_outcome_2018_12);

%inpatient(source=rifq2019.inpatient_claims_01, include_cohort=endo_outcome_2019_1);
%inpatient(source=rifq2019.inpatient_claims_02, include_cohort=endo_outcome_2019_2);
%inpatient(source=rifq2019.inpatient_claims_03, include_cohort=endo_outcome_2019_3);
%inpatient(source=rifq2019.inpatient_claims_04, include_cohort=endo_outcome_2019_4);
%inpatient(source=rifq2019.inpatient_claims_05, include_cohort=endo_outcome_2019_5);
%inpatient(source=rifq2019.inpatient_claims_06, include_cohort=endo_outcome_2019_6);
%inpatient(source=rifq2019.inpatient_claims_07, include_cohort=endo_outcome_2019_7);
%inpatient(source=rifq2019.inpatient_claims_08, include_cohort=endo_outcome_2019_8);
%inpatient(source=rifq2019.inpatient_claims_09, include_cohort=endo_outcome_2019_9);
%inpatient(source=rifq2019.inpatient_claims_10, include_cohort=endo_outcome_2019_10);
%inpatient(source=rifq2019.inpatient_claims_11, include_cohort=endo_outcome_2019_11);
%inpatient(source=rifq2019.inpatient_claims_12, include_cohort=endo_outcome_2019_12);

%inpatient(source=rifq2020.inpatient_claims_01, include_cohort=endo_outcome_2020_1);
%inpatient(source=rifq2020.inpatient_claims_02, include_cohort=endo_outcome_2020_2);
%inpatient(source=rifq2020.inpatient_claims_03, include_cohort=endo_outcome_2020_3);
%inpatient(source=rifq2020.inpatient_claims_04, include_cohort=endo_outcome_2020_4);
%inpatient(source=rifq2020.inpatient_claims_05, include_cohort=endo_outcome_2020_5);
%inpatient(source=rifq2020.inpatient_claims_06, include_cohort=endo_outcome_2020_6);
%inpatient(source=rifq2020.inpatient_claims_07, include_cohort=endo_outcome_2020_7);
%inpatient(source=rifq2020.inpatient_claims_08, include_cohort=endo_outcome_2020_8);
%inpatient(source=rifq2020.inpatient_claims_09, include_cohort=endo_outcome_2020_9);
%inpatient(source=rifq2020.inpatient_claims_10, include_cohort=endo_outcome_2020_10);
%inpatient(source=rifq2020.inpatient_claims_11, include_cohort=endo_outcome_2020_11);
%inpatient(source=rifq2020.inpatient_claims_12, include_cohort=endo_outcome_2020_12);
%inpatient(source=rifq2021.inpatient_claims_01, include_cohort=endo_outcome_2021_01);
%inpatient(source=rifq2021.inpatient_claims_02, include_cohort=endo_outcome_2021_02);
%inpatient(source=rifq2021.inpatient_claims_03, include_cohort=endo_outcome_2021_03);
%inpatient(source=rifq2021.inpatient_claims_04, include_cohort=endo_outcome_2021_04);
%inpatient(source=rifq2021.inpatient_claims_05, include_cohort=endo_outcome_2021_5);
%inpatient(source=rifq2021.inpatient_claims_06, include_cohort=endo_outcome_2021_6);
%inpatient(source=rifq2021.inpatient_claims_07, include_cohort=endo_outcome_2021_7);
%inpatient(source=rifq2021.inpatient_claims_08, include_cohort=endo_outcome_2021_8);
%inpatient(source=rifq2021.inpatient_claims_09, include_cohort=endo_outcome_2021_9);
%inpatient(source=rifq2021.inpatient_claims_10, include_cohort=endo_outcome_2021_10);
%inpatient(source=rifq2021.inpatient_claims_11, include_cohort=endo_outcome_2021_11);
%inpatient(source=rifq2021.inpatient_claims_12, include_cohort=endo_outcome_2021_12);

*allow elective admissions for prior admit variable (do not include date of proc--if admit);
data prior_admit (keep = bene_id endo_dt admit30d_prior);
set endo_outcome: ;
if (endo_dt-30)< CLM_ADMSN_DT<endo_dt then admit30d_prior=1; 
label admit30d_prior='admission 30 days before ERCP for any reason--not including day of admission';
if admit30d_prior ne 1 then delete;
run;
proc sort data=prior_admit NODUPKEY; by bene_id endo_dt; run; 

*non-elective admissions for 30 days after proc (do not include date of proc--if admit);
data after30_admit (keep = bene_id endo_dt admit30d_outcome);
set endo_outcome: ;
where CLM_IP_ADMSN_TYPE_CD ne '3';
*inpatient needs to be admitted later, outp and car can be admitted same day;
	if endo_setting='INP'    then do; if endo_dt< CLM_ADMSN_DT<=(endo_dt+30) then admit30d_outcome=1; end;
	if endo_setting ne 'INP' then do; if endo_dt<=CLM_ADMSN_DT<=(endo_dt+30) then admit30d_outcome=1; end;
label admit30d_outcome='admission 30 days after ERCP non-elective only';
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if CLM_SRC_IP_ADMSN_CD in('4','D') then delete;
if admit30d_outcome ne 1 then delete;
run;
proc sort data=after30_admit NODUPKEY; by bene_id endo_dt; run; 

*non-elective admissions for 7 days after proc (do not include date of proc--if admit);
data after7_admit (keep = bene_id endo_dt admit7d_outcome);
set endo_outcome: ;
where CLM_IP_ADMSN_TYPE_CD ne '3';
*inpatient needs to be admitted later, outp and car can be admitted same day;
	if endo_setting='INP'    then do; if endo_dt< CLM_ADMSN_DT<=(endo_dt+7) then admit7d_outcome=1; end;
	if endo_setting ne 'INP' then do; if endo_dt<=CLM_ADMSN_DT<=(endo_dt+7) then admit7d_outcome=1; end;
label admit7d_outcome='admission 7 days after ERCP non-elective only';
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if CLM_SRC_IP_ADMSN_CD in('4','D') then delete;
if admit7d_outcome ne 1 then delete;
run;
proc sort data=after7_admit NODUPKEY; by bene_id endo_dt; run; 

*POST ERCP PANCREATITIS (PEP) WITHIN 7 DAYS;
*non-elective admissions for 7 days after proc (do not include date of proc--if admit);
data pep7_admit (keep = bene_id endo_dt pep7d_outcome);
set endo_outcome: ;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
		if SUBSTR(dx(i),1,5) in('K9189') then do; pep_outcome=1; end;
	end;
*inpatient needs to be admitted later, outp and car can be admitted same day;
	if pep_outcome=1 then do; if endo_dt< CLM_ADMSN_DT<=(endo_dt+7) then pep7d_outcome=1; end;
label pep7d_outcome='admission for post-ercp pancreatitis 7 days after ERCP only';
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if CLM_SRC_IP_ADMSN_CD in('4','D') then delete;
if pep7d_outcome ne 1 then delete;
run;
proc sort data=pep7_admit NODUPKEY; by bene_id endo_dt; run; 


data after7_infect (keep = bene_id endo_dt endo_admit7_infection);
set endo_outcome: ;
where 	(endo_setting='INP' and endo_dt< CLM_ADMSN_DT<=(endo_dt+7)) 
		OR
		(endo_setting ne 'INP' and endo_dt<=CLM_ADMSN_DT<=(endo_dt+7)) ;
*create infections indicators ;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
		if SUBSTR(dx(i),1,1) in('A','B') then do; endo_admit7_infection = 1; poa_num=i; end;
if substr(dx(i),1,3) 
in( '001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', 
	'013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', 
	'025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', 
	'037', '038', '039', '040', '041', '042', '043', '044', '045', '046', '047', '048', 
	'049', '050', '051', '052', '053', '054', '055', '056', '057', '058', '059', '060', 
	'061', '062', '063', '064', '065', '066', '067', '068', '069', '070', '071', '072', 
	'073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', '084', 
	'085', '086', '087', '088', '089', '090', '091', '092', '093', '094', '095', '096', 
	'097', '098', '099', '100', '101', '102', '103', '104', '105', '106', '107', '108', 
	'109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', 
	'121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', 
	'133', '134', '135', '136', '137', '138', '139', 
	'320', '321', '323', 'G00', 'G01', 'G02', 'G04', 'G05',
	'460', '461', '462', '463', '464', '465', '466',
	'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
	'J09', 'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
	'480', '481', '482', '483', '484', '485', '486', '487', '488', 
	'567', 'K67', 
	'V09', 'Z16') then do; endo_admit7_infection = 1; poa_num=i; end;
	if substr(dx(i),1,4) in ('5070', '5078', 'J690','J698') then do; endo_admit7_aspiration=1;asp_poa_num=i; end;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,2)in('K50','K51') then endo_admit7_ibd=1; end;
	array poa(25) CLM_POA_IND_SW1-CLM_POA_IND_SW25;
		do k = 1 to 25;
			if endo_admit7_infection=1 and poa_num ne . and poa_num=k then do;
				endo_admit7_infection_poa_ind=poa(k); 
			end;
	end;
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if CLM_SRC_IP_ADMSN_CD in('4','D') then delete;
if endo_admit7_infection ne 1 then delete;
run;
proc sort data=after7_infect NODUPKEY; by bene_id endo_dt; run; 

*infection 30 days;
data after30_infect (keep = bene_id endo_dt endo_admit30_infection);
set endo_outcome: ;
where 	(endo_setting='INP' and endo_dt< CLM_ADMSN_DT<=(endo_dt+30)) 
		OR
		(endo_setting ne 'INP' and endo_dt<=CLM_ADMSN_DT<=(endo_dt+30)) ;
*create infections indicators ;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
	do i=1 to 25;
		if SUBSTR(dx(i),1,1) in('A','B') then do; endo_admit30_infection = 1; poa_num=i; end;
if substr(dx(i),1,3) 
in( '001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', 
	'013', '014', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', 
	'025', '026', '027', '028', '029', '030', '031', '032', '033', '034', '035', '036', 
	'037', '038', '039', '040', '041', '042', '043', '044', '045', '046', '047', '048', 
	'049', '050', '051', '052', '053', '054', '055', '056', '057', '058', '059', '060', 
	'061', '062', '063', '064', '065', '066', '067', '068', '069', '070', '071', '072', 
	'073', '074', '075', '076', '077', '078', '079', '080', '081', '082', '083', '084', 
	'085', '086', '087', '088', '089', '090', '091', '092', '093', '094', '095', '096', 
	'097', '098', '099', '100', '101', '102', '103', '104', '105', '106', '107', '108', 
	'109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', 
	'121', '122', '123', '124', '125', '126', '127', '128', '129', '130', '131', '132', 
	'133', '134', '135', '136', '137', '138', '139', 
	'320', '321', '323', 'G00', 'G01', 'G02', 'G04', 'G05',
	'460', '461', '462', '463', '464', '465', '466',
	'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
	'J09', 'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
	'480', '481', '482', '483', '484', '485', '486', '487', '488', 
	'567', 'K67', 
	'V09', 'Z16') then do; endo_admit30_infection = 1; poa_num=i; end;
	end;
	array poa(25) CLM_POA_IND_SW1-CLM_POA_IND_SW25;
		do k = 1 to 25;
			if endo_admit30_infection=1 and poa_num ne . and poa_num=k then do;
				endo_admit30_infection_poa_ind=poa(k); 
			end;
	end;
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if CLM_SRC_IP_ADMSN_CD in('4','D') then delete;
if endo_admit30_infection ne 1 then delete;
run;
proc sort data=after30_infect NODUPKEY; by bene_id endo_dt; run; 

*link admit prior to eligibility with full cohort and make indicator of admission;
proc sort data=prior_admit; by bene_id endo_dt; run;*admission 30 days prior to eligible;
*outcomes;
proc sort data=after30_admit; by bene_id endo_dt; run;
proc sort data=after7_admit; by bene_id endo_dt; run;
proc sort data=after30_infect; by bene_id endo_dt; run;
proc sort data=after7_infect; by bene_id endo_dt; run;
proc sort data=pep7_admit; by bene_id endo_dt; run;
*eligible;
proc sort data=endo_ercp; by bene_id endo_dt; run; 
data endo_ercp_outcome1;
merge prior_admit pep7_admit after30_admit after7_admit after30_infect after7_infect endo_ercp (in=c);
by bene_id endo_dt;
 if c;
if endo_admit7_infection=. then endo_admit7_infection=0;
if endo_admit30_infection=. then endo_admit30_infection=0;
if admit7d_outcome=. then admit7d_outcome=0;
if admit30d_outcome=. then admit30d_outcome=0;
if admit30d_prior=. then admit30d_prior=0;
if pep7d_outcome=. then pep7d_outcome=0;
if     endo_age<65 then endo_age_cat=' 0-64';
if 65<=endo_age<75 then endo_age_cat='65-74';
if 75<=endo_age<85 then endo_age_cat='75-84';
if 85<=endo_age<95 then endo_age_cat='85-94';
if 95<=endo_age    then endo_age_cat='95-  ';
month=month(endo_dt);
year=year(endo_dt);
if endo_c1748=. then  endo_c1748=0;
run; 
*only keep 1 outcome per endo date by sorting no dup by endo date--DO this before each outcome model
	otherwise will not capture all unique outcome types;
	/*proc sort data=endo_ercp_outcome1 nodupkey; by bene_id endo_dt ; run;*/
%macro outcomepercent(outcome=);
proc sort data=endo_ercp_outcome1 nodupkey out=calcpercent; by bene_id endo_dt &outcome; run;
proc freq data=calcpercent;
table  &outcome endo_c1748*&outcome inpatient*&outcome ed*&outcome;
run;
%mend;
%outcomepercent(outcome=endo_admit7_infection);
%outcomepercent(outcome=endo_admit30_infection);
%outcomepercent(outcome=admit7d_outcome);
%outcomepercent(outcome=admit30d_outcome);
%outcomepercent(outcome=pep7d_outcome);

*assign 20% to infected scope;
DATA random2 (keep = infected_scope);    
DO i=1 to 1000000;   *n should match n from final dataset or be higher;   
x = UNIFORM(123456);      
IF x>.2 THEN infected_scope = 0;        ELSE infected_scope = 1;      
OUTPUT;    END;  
RUN;     PROC FREQ DATA=random2;    table infected_scope;  RUN; 
proc print data=random2 (obs=10); run; 

data endo_ercp_outcome2;
merge endo_ercp_outcome1 random2;
if endo_c1748=1 then infected_scope=0;*disposable scopes can't be contaminated in this simulation;
if bene_id=. then delete;
run;
proc freq data=endo_ercp_outcome2; table infected_scope*endo_admit7_infection endo_c1748*infected_scope; run;
 
*link to mbsf;
*bring in chronic conditions;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, a.endo_dt, b.*
from 
endo_ercp_outcome2 a,
&abcd b
where a.bene_id = b.bene_id;* and a.year = b.BENE_ENROLLMT_REF_YR;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2021, include_cohort=cc_2021);
%line(abcd=mbsf.mbsf_cc_2020, include_cohort=cc_2020);
%line(abcd=mbsf.mbsf_cc_2019, include_cohort=cc_2019);
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=cc_2018); 
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=cc_2017); 
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=cc_2016); 
%line(abcd=mbsf.mbsf_cc_2015, include_cohort=cc_2015); 
%line(abcd=mbsf.mbsf_otcc_2021, include_cohort=otcc_2021);
%line(abcd=mbsf.mbsf_otcc_2020, include_cohort=otcc_2020);
%line(abcd=mbsf.mbsf_otcc_2019, include_cohort=otcc_2019); 
%line(abcd=mbsf.mbsf_otcc_2018, include_cohort=otcc_2018); 
%line(abcd=mbsf.mbsf_otcc_2017, include_cohort=otcc_2017); 
%line(abcd=mbsf.mbsf_otcc_2016, include_cohort=otcc_2016); 
%line(abcd=mbsf.mbsf_otcc_2015, include_cohort=otcc_2015); 


proc sort data=cc_2016; by bene_id endo_dt;
proc sort data=cc_2017; by bene_id endo_dt;
proc sort data=cc_2018; by bene_id endo_dt;
proc sort data=cc_2019; by bene_id endo_dt;
proc sort data=cc_2020; by bene_id endo_dt;
proc sort data=cc_2021; by bene_id endo_dt;

proc sort data=otcc_2016; by bene_id endo_dt;
proc sort data=otcc_2017; by bene_id endo_dt;
proc sort data=otcc_2018; by bene_id endo_dt;
proc sort data=otcc_2019; by bene_id endo_dt;
proc sort data=otcc_2020; by bene_id endo_dt;
proc sort data=otcc_2021; by bene_id endo_dt;
proc sort data=endo_ercp_outcome2; by bene_id endo_dt;
run;
data cc (keep=bene_id endo_dt BENE_ENROLLMT_REF_YR enrl_src ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever 
acp_MEDICARE_EVER anxi_MEDICARE_EVER autism_MEDICARE_EVER bipl_MEDICARE_EVER brainj_MEDICARE_EVER cerpal_MEDICARE_EVER
cysfib_MEDICARE_EVER depsn_MEDICARE_EVER epilep_MEDICARE_EVER fibro_MEDICARE_EVER hearim_MEDICARE_EVER
hepviral_MEDICARE_EVER hivaids_MEDICARE_EVER intdis_MEDICARE_EVER leadis_MEDICARE_EVER leuklymph_MEDICARE_EVER
liver_MEDICARE_EVER migraine_MEDICARE_EVER mobimp_MEDICARE_EVER mulscl_MEDICARE_EVER musdys_MEDICARE_EVER
obesity_MEDICARE_EVER othdel_MEDICARE_EVER psds_MEDICARE_EVER ptra_MEDICARE_EVER pvd_MEDICARE_EVER schi_MEDICARE_EVER
schiot_MEDICARE_EVER spibif_MEDICARE_EVER spiinj_MEDICARE_EVER toba_MEDICARE_EVER ulcers_MEDICARE_EVER
visual_MEDICARE_EVER cc_sum cc_other_sum cc_DHHS_sum);
;
merge otcc_2: cc_2:	;
by bene_id endo_dt;
*make chronic conitions indicators;
if ami_ever ne . and ami_ever<=endo_dt then cc_ami=1; else cc_ami=0;
if alzh_ever ne . and alzh_ever <=endo_dt then cc_alzh=1; else cc_alzh=0;
if alzh_demen_ever ne . and alzh_demen_ever <=endo_dt then cc_alzh_demen=1; else cc_alzh_demen=0;
if atrial_fib_ever ne . and atrial_fib_ever<=endo_dt then cc_atrial_fib=1; else cc_atrial_fib=0;
if cataract_ever ne . and cataract_ever <=endo_dt then cc_cataract=1; else cc_cataract=0;
if chronickidney_ever ne . and chronickidney_ever<=endo_dt then cc_chronickidney=1; else cc_chronickidney=0;
if copd_ever ne . and copd_ever <=endo_dt then cc_copd=1; else cc_copd=0;
if chf_ever ne . and chf_ever <=endo_dt then cc_chf=1; else cc_chf=0;
if diabetes_ever ne . and diabetes_ever <=endo_dt then cc_diabetes=1; else cc_diabetes=0;
if glaucoma_ever ne . and glaucoma_ever  <=endo_dt then cc_glaucoma=1; else cc_glaucoma=0;
if hip_fracture_ever ne . and hip_fracture_ever <=endo_dt then cc_hip_fracture=1; else cc_hip_fracture=0;
if ischemicheart_ever ne . and ischemicheart_ever<=endo_dt then cc_ischemicheart=1; else cc_ischemicheart=0;
if depression_ever ne . and depression_ever <=endo_dt then cc_depression=1; else cc_depression=0;
if osteoporosis_ever ne . and osteoporosis_ever <=endo_dt then cc_osteoporosis=1; else cc_osteoporosis=0;
if ra_oa_ever ne . and ra_oa_ever <=endo_dt then cc_ra_oa=1; else cc_ra_oa=0;
if stroke_tia_ever  ne . and stroke_tia_ever <=endo_dt then cc_stroke_tia=1; else cc_stroke_tia=0;
if cancer_breast_ever ne . and cancer_breast_ever<=endo_dt then cc_cancer_breast=1; else cc_cancer_breast=0;
if cancer_colorectal_ever ne . and cancer_colorectal_ever<=endo_dt then cc_cancer_colorectal=1; else cc_cancer_colorectal=0;
if cancer_prostate_ever ne . and cancer_prostate_ever <=endo_dt then cc_cancer_prostate=1; else cc_cancer_prostate=0;
if cancer_lung_ever ne . and cancer_lung_ever <=endo_dt then cc_cancer_lung=1; else cc_cancer_lung=0;
if cancer_endometrial_ever ne . and cancer_endometrial_ever<=endo_dt then cc_cancer_endometrial=1; else cc_cancer_endometrial=0;
if anemia_ever ne . and anemia_ever <=endo_dt then cc_anemia=1; else cc_anemia=0;
if asthma_ever ne . and asthma_ever<=endo_dt then cc_asthma=1; else cc_asthma=0;
if hyperl_ever ne . and hyperl_ever <=endo_dt then cc_hyperl=1; else cc_hyperl=0;
if hyperp_ever ne . and hyperp_ever <=endo_dt then cc_hyperp=1; else cc_hyperp=0;
if hypert_ever ne . and hypert_ever <=endo_dt then cc_hypert=1; else cc_hypert=0;
if hypoth_ever ne . and hypoth_ever<=endo_dt then cc_hypoth=1; else cc_hypoth=0;
cc_sum=sum(cc_ami, cc_alzh, cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_glaucoma, cc_hip_fracture,
cc_ischemicheart, cc_depression, cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate,
cc_cancer_lung, cc_cancer_endometrial, cc_anemia, cc_asthma, cc_hyperl, cc_hyperp, cc_hypert, cc_hypoth);
if ACP_MEDICARE_EVER ne . and ACP_MEDICARE_EVER<=endo_dt then cc_acp=1; else cc_acp=0;
if ANXI_MEDICARE_EVER ne . and ANXI_MEDICARE_EVER<=endo_dt then cc_anxi=1; else cc_anxi=0;
if AUTISM_MEDICARE_EVER ne . and AUTISM_MEDICARE_EVER<= endo_dt then cc_autism=1; else cc_autism=0;
if BIPL_MEDICARE_EVER ne . and BIPL_MEDICARE_EVER<=endo_dt then cc_bipl=1; else cc_bipl=0;
if BRAINJ_MEDICARE_EVER ne . and BRAINJ_MEDICARE_EVER<=endo_dt then cc_brainj=1; else cc_brainj=0;
if CERPAL_MEDICARE_EVER ne . and CERPAL_MEDICARE_EVER<=endo_dt then cc_cerpal=1; else cc_cerpal=0;
if CYSFIB_MEDICARE_EVER ne . and CYSFIB_MEDICARE_EVER<=endo_dt then cc_cysfib=1; else cc_cysfib=0;
if DEPSN_MEDICARE_EVER ne . and DEPSN_MEDICARE_EVER<=endo_dt then cc_depsn=1; else cc_depsn =0;
if EPILEP_MEDICARE_EVER ne . and EPILEP_MEDICARE_EVER<=endo_dt then cc_epilep=1; else cc_epilep=0;
if FIBRO_MEDICARE_EVER ne . and FIBRO_MEDICARE_EVER<=endo_dt then cc_fibro=1; else cc_fibro=0;
if HEARIM_MEDICARE_EVER ne . and HEARIM_MEDICARE_EVER<=endo_dt then cc_hearim=1; else cc_hearim=0;
if HEPVIRAL_MEDICARE_EVER ne . and HEPVIRAL_MEDICARE_EVER<=endo_dt then cc_hepviral=1; else cc_hepviral=0;
if HIVAIDS_MEDICARE_EVER ne . and HIVAIDS_MEDICARE_EVER<=endo_dt then cc_hivaids=1; else cc_hivaids=0;
if INTDIS_MEDICARE_EVER ne . and INTDIS_MEDICARE_EVER<=endo_dt then cc_intdis=1; else cc_intdis=0;
if LEADIS_MEDICARE_EVER ne . and LEADIS_MEDICARE_EVER<=endo_dt then cc_leadis=1; else cc_leadis=0; 
if LEUKLYMPH_MEDICARE_EVER ne . and LEUKLYMPH_MEDICARE_EVER<=endo_dt then cc_leuklymph=1; else cc_leuklymph=0;
if LIVER_MEDICARE_EVER ne . and LIVER_MEDICARE_EVER<=endo_dt then cc_liver=1; else cc_liver=0; 
if MIGRAINE_MEDICARE_EVER ne . and MIGRAINE_MEDICARE_EVER<=endo_dt then cc_migraine=1; else cc_migraine=0; 
if MOBIMP_MEDICARE_EVER ne . and MOBIMP_MEDICARE_EVER<=endo_dt then cc_mobimp=1; else cc_mobimp=0; 
if MULSCL_MEDICARE_EVER ne . and MULSCL_MEDICARE_EVER<=endo_dt then cc_mulscl=1; else cc_mulscl=0; 
if MUSDYS_MEDICARE_EVER ne . and MUSDYS_MEDICARE_EVER<=endo_dt then cc_musdys=1; else cc_musdys=0;
if OBESITY_MEDICARE_EVER ne . and OBESITY_MEDICARE_EVER<=endo_dt then cc_obesity=1; else cc_obesity=0;
if OTHDEL_MEDICARE_EVER ne . and OTHDEL_MEDICARE_EVER<=endo_dt then cc_othdel=1; else cc_othdel=0;
if PSDS_MEDICARE_EVER ne . and PSDS_MEDICARE_EVER<=endo_dt then cc_psds=1; else cc_psds=0;
if PTRA_MEDICARE_EVER ne . and PTRA_MEDICARE_EVER<=endo_dt then cc_ptra=1; else cc_ptra=0;
if PVD_MEDICARE_EVER ne . and PVD_MEDICARE_EVER<=endo_dt then cc_pvd=1; else cc_pvd=0;
if SCHI_MEDICARE_EVER ne . and SCHI_MEDICARE_EVER<=endo_dt then cc_schi=1; else cc_schi=0;
if SCHIOT_MEDICARE_EVER ne . and SCHIOT_MEDICARE_EVER<=endo_dt then cc_schiot=1; else cc_schiot=0;
if SPIBIF_MEDICARE_EVER ne . and SPIBIF_MEDICARE_EVER<=endo_dt then cc_spibif=1; else cc_spibif=0;
if SPIINJ_MEDICARE_EVER ne . and SPIINJ_MEDICARE_EVER<=endo_dt then cc_spiinj=1; else cc_spiinj=0;
if TOBA_MEDICARE_EVER ne . and TOBA_MEDICARE_EVER<=endo_dt then cc_toba=1; else cc_toba=0;
if ULCERS_MEDICARE_EVER ne . and ULCERS_MEDICARE_EVER<=endo_dt then cc_ulcers=1; else cc_ulcers=0;
if VISUAL_MEDICARE_EVER ne . and VISUAL_MEDICARE_EVER<=endo_dt then cc_visual=1; else cc_visual=0;
cc_other_sum=sum(cc_acp, cc_anxi, cc_autism, cc_bipl, cc_brainj, cc_cerpal, cc_cysfib, cc_depsn, cc_epilep, 
cc_fibro, cc_hearim, cc_hepviral, cc_hivaids, cc_intdis, cc_leadis, cc_leuklymph, cc_liver, cc_migraine, 
cc_mobimp, cc_mulscl, cc_musdys, cc_obesity, cc_othdel, cc_psds, cc_ptra, cc_pvd, cc_schi, cc_schiot, 
cc_spibif, cc_spiinj, cc_toba, cc_ulcers, cc_visual); 
*DHHS has own chronic conditions list which is a subset of these CC
https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Chronic-Conditions/Downloads/Methods_Overview.pdf ;
cc_DHHS_sum=sum(cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_ischemicheart, cc_depression,
cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate, cc_cancer_lung, cc_asthma,
cc_hyperl, cc_hypert,cc_autism, cc_hepviral, cc_hivaids, cc_schi);
run;
proc sort data=cc; by bene_id endo_dt descending BENE_ENROLLMT_REF_YR; run;
proc sort data=cc NODUPKEY; by bene_id endo_dt; run;

data endo_ercp_outcome;
merge 
cc (in=a) endo_ercp_outcome2 (in=b);
by bene_id endo_dt;
if b;
if cc_sum=0 then 	   cc_cat=0;
if 1<=cc_sum<=5 then   cc_cat=1;
if 6<=cc_sum<=10 then  cc_cat=2;
if 11<=cc_sum<=15 then cc_cat=3;
if 16<=cc_sum     then cc_cat=4;
if cc_sum=. 	  then cc_cat=0;
*assign inpatient vs other;
if endo_NCH_CLM_TYPE_CD='60' or endo_setting='INP' or inp_pos=1 then inpatient=1; else inpatient=0;
if bene_id=. then delete;
*delete those with infection at time of procedure;
*if endo_infect_at_proc=1 then delete;
*delete those we can't identify as inpatient or outpatient;
*if endo_NCH_CLM_TYPE_CD='71' then delete; 
*change other race to missing;
if endo_bene_race_cd=3 then endo_bene_race_cd=0;
*if ed=1 then elective=0;
*if elective=. then elective=1;
if endo_PEP_at_proc=. then endo_PEP_at_proc=0;
*assign npi to all;
if endo_prf_PHYSN_NPI=' ' then endo_prf_PHYSN_NPI=endo_OP_PHYSN_NPI;
run; 
data &permlib..endo_ercp_outcome; set endo_ercp_outcome;run;


/******REMEMBER TO DE-DUPE BY OUTCOME TYPE WHEN CALCULATING RESULTS
SINCE STUDY INCLUDES MULTIPLE OUTCOME TYPES********/

%macro groupfreqs(group=, var=);
*ods trace on;
ods output onewayfreqs =&var;
proc freq data=endo_ercp_outcome; *where endo_admit7_infection=1; 
table 
&var;
run;
ods output close;
*ods trace off;
data &var (drop = table f_&var frequency cumfrequency cumpercent &var); 
retain group var label; 
format label $40.;
set &var;
group=&group;
var="&var";
label=&var;
if frequency<11 then frequency=.;
if cumfrequency<11 then cumfrequency=.;
run;
%mend;
%groupfreqs(group="all", var=endo_year); *group should match where clause--enter where clause manually;
%groupfreqs(group="all", var=endo_age_cat);
%groupfreqs(group="all", var=endo_gndr_cd);
%groupfreqs(group="all", var=endo_bene_race_cd );
*%groupfreqs(group="all", var=elective);
%groupfreqs(group="all", var=ed);
%groupfreqs(group="all", var=admit30d_prior);
%groupfreqs(group="all", var=endo_cancer_at_proc );
%groupfreqs(group="all", var=endo_panc_at_proc);
%groupfreqs(group="all", var=endo_infect_at_proc);
%groupfreqs(group="all", var=endo_PEP_at_proc);
%groupfreqs(group="all", var=cc_cat);
%groupfreqs(group="all", var=endo_NCH_CLM_TYPE_CD);
%groupfreqs(group="all", var=endo_setting);
%groupfreqs(group="all", var=inpatient);
%groupfreqs(group="all", var=infected_scope);
%groupfreqs(group="all", var=endo_c1748);
%groupfreqs(group="all", var=endo_admit7_infection);
%groupfreqs(group="all", var=endo_admit30_infection);
%groupfreqs(group="all", var=admit7d_outcome);
%groupfreqs(group="all", var=admit30d_outcome);
%groupfreqs(group="all", var=pep7d_outcome);
*output to a single table and request out;
data all; 
set endo_year endo_age_cat endo_gndr_cd endo_bene_race_cd 
/*elective*/ ed admit30d_prior
endo_cancer_at_proc endo_panc_at_proc endo_infect_at_proc endo_PEP_at_proc
cc_cat endo_NCH_CLM_TYPE_CD endo_setting inpatient  infected_scope endo_c1748
 endo_admit7_infection
endo_admit30_infection
admit7d_outcome
admit30d_outcome
pep7d_outcome
;
run;
*get Ns for groups that you made above for;
proc freq data=endo_ercp_outcome;
table endo_admit7_infection endo_setting;
run;

*1	White
2	Black
3	Other
4	Asian
5	Hispanic
6	North American Native;

*use for table of disposable vs reusable;
proc freq data=endo_ercp_outcome; 
where endo_c1748=1 and endo_setting='OUT' and endo_dt>='01jul2020'd;
table  
endo_year
endo_age_cat endo_gndr_cd endo_bene_race_cd   
/*elective*/ inpatient ed admit30d_prior 
endo_cancer_at_proc endo_panc_at_proc endo_infect_at_proc endo_PEP_at_proc
cc_cat 
endo_NCH_CLM_TYPE_CD endo_setting inpatient  infected_scope endo_c1748
endo_admit7_infection
endo_admit30_infection
admit30d_outcome
admit7d_outcome
pep7d_outcome; run;

*for appendix table start;
 proc freq data=endo_ercp_outcome;
 where endo_year=2017;
 table endo_setting*endo_admit7_infection;
 run;
  proc freq data=endo_ercp_outcome;
 where endo_year=2017 and endo_cancer_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
 proc freq data=endo_ercp_outcome;
 where endo_year=2017 and endo_panc_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
 proc freq data=endo_ercp_outcome;
 where endo_year=2017 and endo_cancer_at_proc=1 and endo_panc_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
proc freq data=endo_ercp_outcome;
 where endo_year=2017 and admit30d_prior=1;
 table endo_setting*endo_admit7_infection;
 run;

 *for appendix table stop;*/
