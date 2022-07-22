*read in data;
*%include "S:\CMS\AHRQ HCUP downloads\MD_2017\MD_SASD_2017_CORE.sas";
*%include "S:\CMS\AHRQ HCUP downloads\MD_2017\MD_SID_2017_CORE.sas";
*read in elixhauser macros;
%include "S:\CMS\AHRQ HCUP downloads\elixhauser_calculation_icd9.sas";
%include "S:\CMS\AHRQ HCUP downloads\elixhauser_calculation_icd10.sas";
%include "S:\CMS\AHRQ HCUP downloads\NLEstimate macro.sas";
run;

*make macro to do same ercp and outcome identification for 
each state;
%macro statecalc(lib=, table=);
libname &lib "S:\CMS\AHRQ HCUP downloads\&table._2017"; run; 

/*proc contents data=&lib..&table._SIDC_2017_CORE; run;
proc contents data=&lib..&table._SASDC_2017_CORE; run;
proc freq data=md2017.md_SIDC_2017_CORE (obs=100); 
where i10_pr1 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ');
table I10_PR1; run;*/

*identify procedures in outpatient setting -- label as asc/OUT;
data &table._asc (keep= visitlink endo: I10: elective); 
set &lib..&table._SASDC_2017_CORE;
array cpt(100) cpt1-cpt100;
do i=1 to 100;
	if cpt(i) 
		in ('43260','43261','43262','43263','43264','43265','43274','43275','43276','43277','43278','43273') 
	then ercp=1;
end;
/*array pr(30) I10_PR1 - I10_PR30;
do i=1 to 30;
	if pr(i) 
		 in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ')
	then ercp=1;
end;*/
if ercp ne 1 then delete;
endo_dt=daystoevent;
endo_daystoevent=daystoevent;
endo_age=age;
endo_bene_race_cd=race;
endo_bene_state_cd=pstate; 
endo_gndr_cd=female;
endo_year=year;
endo_icd_dgns_cd1=i10_dx1;
*if had an infection on index procedure ;
array dx(30) i10_dx1 - i10_dx30;
	do i=1 to 30;
		*Infection recorded at time of procedure;
		if SUBSTR(dx(i),1,1) in('A','B') then do; endo_infect_at_proc=1; end;
		*Any type of cancer at procedure;
		if SUBSTR(dx(i),1,1) in('C') then do; endo_cancer_at_proc=1; end;
		*Disorders of gallbladder, biliary tract and pancreas;
		if SUBSTR(dx(i),1,3) in('K80', 'K81','K82','K83','K84','K85','K86','K87') then do; 
			endo_PANC_at_proc=1; end;
		*post ercp pancreatitis at procedure;
		if SUBSTR(dx(i),1,5) in('K9189') then do; endo_PEP_at_proc=1; end;
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
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3) in('K50','K51') then endo_ibd_at_proc=1; end;
if endo_infect_at_proc=. then  endo_infect_at_proc=0;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if endo_PANC_at_proc=. then endo_PANC_at_proc=0;
if endo_ibd_at_proc=. then endo_ibd_at_proc=0;
if endo_PEP_at_proc=. then endo_PEP_at_proc=0;
*label those admitted through emergency room (previously delete non-elective);
if hcup_ed>0 then elective=0;
if hcup_ed=0 then elective=1;
*if HCUP_ED>0 then delete;
*label those with infection at admission (previously deleted);
if endo_infect_at_proc ne 1 then endo_infect_at_proc=0;
*if endo_infect_at_proc=1 then delete;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
endo_setting='OUT';
if pay1=1 then endo_medicare=1; 
run;

/*for info prior to exclusion of those with infection at time of procedure;
proc freq data=&table._asc;
table HCUP_ED endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_ibd_at_proc pay1;
run;
*infection at procedure among those with medicare;
proc freq data=&table._asc; where pay1=1;
table endo_infect_at_proc pay1;
run;*/



/*proc contents data=&lib..&table._SIDC_2017_CORE; run;*/
*identify procedures in inpatient setting -- label as INP;
data &table._inp (keep= visitlink endo: I10: elective /*I10_dx1 pay1 i10_pr1  DXPOA1 atype*/); 
set &lib..&table._SIDC_2017_CORE;
*not all states have cpt in inpatient;
array cpt(100) cpt1 - cpt100;
	do j=1 to 100;
	if cpt(j) in('43260','43261','43262','43263','43264','43265','43274','43275',
						  '43276','43277','43278','43273') then ercp=1;
end;
array pr(30) I10_PR1 - I10_PR30;
	do i=1 to 30;
		if pr(i) ne ' ' 
			and 
			pr(i) in ('5110', '0FJB8ZZ', '0FJD8ZZ', 'BF110ZZ', 'BF111ZZ', 'BF11YZZ',
					  '43260','43261','43262','43263','43264','43265','43274','43275',
					  '43276','43277','43278','43273')
		then ercp=1;
end;
if ercp ne 1 then delete;
endo_dt=daystoevent;
endo_daystoevent=daystoevent;
endo_age=age;
endo_bene_race_cd=race;
endo_bene_state_cd=pstate; 
endo_gndr_cd=female;
endo_year=year;
endo_icd_dgns_cd1=i10_dx1;
*if had an infection POA on index procedure then delete;
array dx(30) I10_DX1 - I10_DX30;
do i=1 to 30;
		*Any type of cancer at procedure;
		if SUBSTR(dx(i),1,1) in('C') then do; endo_cancer_at_proc=1; end;
		*Disorders of gallbladder, biliary tract and pancreas;
		if SUBSTR(dx(i),1,3) in('K80', 'K81','K82','K83','K84','K85','K86','K87') then do; 
			endo_PANC_at_proc=1; end;
		*post ercp pancreatitis at procedure;
		if SUBSTR(dx(i),1,5) in('K9189') then do; endo_PEP_at_proc=1; end;
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
	'V09', 'Z16') then do; 
		endo_infect_at_proc=11; poa_num=i; end; 
		if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3) in('K50','K51') then do; endo_ibd_at_proc=1;end;
end;
	array poa(30) DXPOA1-DXPOA30;
		do k = 1 to 30;
			if endo_infect_at_proc=11 and poa(k) ='Y' and poa_num=k then do;
				endo_infect_at_proc=1; 
			end;
			*if infection not poa then they have an infection during hosp--have an outcome;
			if endo_infect_at_proc=11 and poa(k) ='N' and poa_num=k then do;
				endo_admit7_infection  =1; 
				endo_admit30_infection =1;
			end;
			
	end;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if endo_PANC_at_proc=. then endo_PANC_at_proc=0;
if endo_ibd_at_proc=. then endo_ibd_at_proc=0;
if endo_PEP_at_proc=. then endo_PEP_at_proc=0;
*label those elective (previously delete non-elective);
if atype ne '3' then elective=0;
if atype = '3' then elective=1;
*if HCUP_ED>0 then delete;
*label those with infection at admission (previously deleted);
	*11 is had an infection but 1 is had an infection and poa=y;
if endo_infect_at_proc ne 1 then endo_infect_at_proc=0;
*if endo_infect_at_proc=1 then delete;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
endo_setting='INP';
if pay1=1 then endo_medicare=1; 
run;
proc freq data=&table._inp; table endo_infect_at_proc endo_medicare/*poa_num DXPOA1*/; run;
*in maryland, 60 before excluded poa, 55 after poa exclusion;


/*for info prior to exclusion of those with infection at time of procedure;
proc freq data=&table._inp;
table atype endo_infect_at_proc endo_cancer_at_proc endo_PANC_at_proc endo_ibd_at_proc pay1 DXPOA1;
run;
*infection at procedure among those with medicare;
proc freq data=&table._inp; where pay1=1;
table endo_infect_at_proc pay1 atype DXPOA1;
run;*/

*bring inpatient and outpatient procedures together;
data &table._asc_inp;
set
	&table._asc
	&table._inp;
*limit to time period of interest;
if endo_year<2015 then delete;
if endo_year>2021 then delete;
*delete those who did not have an elective admit type or were admitted through emergency;
*if endo_setting='INP' and atype ne '3' then delete;
*if endo_setting='OUT' and HCUP_ED>0 then delete;*https://www.hcup-us.ahrq.gov/db/vars/hcup_ed/nisnote.jsp;
*delete those with infection at admission;
*if endo_infect_at_proc=1 then delete;
run;

proc freq data=&table._asc_inp;
table endo_setting endo_infect_at_proc; 
run;


*calculate elixhauser comorbidities at time of procedure;
%_ElixhauserICD10 (DATA    =&table._asc_inp,
                       OUT     =&table._asc_inp2,
                       dx      =I10_DX1-I10_DX58) ;


data &table._asc_inp3 (keep= visitlink endo: elective tot_grp elx_:); set &table._asc_inp2;
run;
proc freq data=&table._asc_inp3; table tot_grp elx:; run;

%mend;
title 'FL';
%statecalc(lib=fl2017, table=FL);
title 'GA';
%statecalc(lib=ga2017, table=GA);
title 'IA';
%statecalc(lib=ia2017, table=IA);
title 'MD';
%statecalc(lib=md2017, table=MD);
title 'WI';
%statecalc(lib=wi2017, table=WI);

*link to hospitalizations--same macro name as eligible for outcomes;
%macro statecalc(lib=, table=);
proc sql;* inobs=100000;
create table hosps (compress=yes) as
select a.visitlink, a.endo_daystoevent, a.endo_setting, b.*
from 
&table._asc_inp3 a, 
&lib..&table._SIDC_2017_CORE b 
where a.visitlink=b.visitlink and b.visitlink ne .;
*and (a.endo_daystoevent-30)<=b.daystoevent<=(a.endo_daystoevent+30);*keep up to 7 days after;
*and (a.endo_daystoevent-30)<=b.daystoevent<=(a.endo_daystoevent+365) /*keep all admissions 30 days before to 1 year after*/
;
quit; 

data prior_admit (keep = visitlink endo_daystoevent admit30d_prior);
set hosps ;
if (endo_daystoevent-30)<= daystoevent <endo_daystoevent then admit30d_prior=1; 
label admit30d_prior='admission 30 days before ERCP for any reason';
if admit30d_prior ne 1 then delete;
run;
proc sort data=prior_admit NODUPKEY; by visitlink endo_daystoevent; run; 

proc contents data=hosps; run;
*7 day infection outcome;
data after7_infect (keep = visitlink endo_daystoevent endo_admit7_infection);
set hosps;
where 	(endo_setting='INP' and endo_daystoevent< daystoevent<=(endo_daystoevent+7)) 
		OR
		(endo_setting ne 'INP' and endo_daystoevent<=daystoevent<=(endo_daystoevent+7)) ;
*create infections indicators ;
	array dx(30) i10_dx1 - i10_dx30;
	do i=1 to 30;
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
	if substr(dx(i),1,4) in ('5070', '5078', 'J690','J698') then do; endo_admit7_aspiration=1;*poa_num=i; end;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3)in('K50','K51') then endo_admit7_ibd=1; end;
	/*array poa(30) DXPOA1-DXPOA30;
		do k = 1 to 30;
			if endo_admit7_infection=1 and poa_num ='Y' and poa_num=k then do;
				endo_admit7_infection_poa_ind=poa(k); 
			end;
	end;*/
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if asource ='2' then delete;
if endo_admit7_infection ne 1 then delete;
run;
proc sort data=after7_infect NODUPKEY; by visitlink endo_daystoevent; run; 


*30 day infection outcome;
data after30_infect (keep = visitlink endo_daystoevent endo_admit30_infection);
set hosps ;
where 	(endo_setting='INP' and endo_daystoevent< daystoevent<=(endo_daystoevent+30)) 
		OR
		(endo_setting ne 'INP' and endo_daystoevent<=daystoevent<=(endo_daystoevent+30)) ;
*create infections indicators ;
	array dx(30) i10_dx1 - i10_dx30;
	do i=1 to 30;
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
	if substr(dx(i),1,4) in ('5070', '5078', 'J690','J698') then do; endo_admit30_aspiration=1;*poa_num=i; end;
	if substr(dx(i),1,3) in('555','556') or substr(dx(i),1,3)in('K50','K51') then endo_admit30_ibd=1; end;
	/*array poa(30) DXPOA1-DXPOA30;
		do k = 1 to 30;
			if endo_admit30_infection=1 and poa_num ='Y' and poa_num=k then do;
				endo_admit30_infection_poa_ind=poa(k); 
			end;
	end;*/
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if asource ='2' then delete;
if endo_admit30_infection ne 1 then delete;
run;
proc sort data=after30_infect NODUPKEY; by visitlink endo_daystoevent; run; 

*POST ERCP PANCREATITIS (PEP) WITHIN 7 DAYS;
*non-elective admissions for 7 days after proc (do not include date of proc--if admit);
data pep7_admit (keep = visitlink endo_daystoevent pep7d_outcome);
set hosps ;
	array dx(30) i10_dx1 - i10_dx30;
	do i=1 to 30;
		if SUBSTR(dx(i),1,5) in('K9189') then do; pep_outcome=1; end;
	end;
*inpatient needs to be admitted later, outp and car can be admitted same day;
	if pep_outcome=1 then do; if endo_daystoevent<daystoevent<=(endo_daystoevent+7) then pep7d_outcome=1; end;
label pep7d_outcome='admission for post-ercp pancreatitis 7 days after ERCP only';
*delete those transferred  from another hospital or within same hospital--allow transfer from SNF or other facility;
if asource ='2' then delete;
if pep7d_outcome ne 1 then delete;
run;
proc sort data=pep7_admit NODUPKEY; by visitlink endo_daystoevent; run; 

*bring prior admit and infections together with procedures;
proc sort data=prior_admit; by visitlink endo_daystoevent; run;
proc sort data=after7_infect; by visitlink endo_daystoevent; run;
proc sort data=after30_infect; by visitlink endo_daystoevent; run;
proc sort data=pep7_admit; by visitlink endo_daystoevent; run;
proc sort data=&table._asc_inp3; by visitlink endo_daystoevent; run;
data endo_ercp_outcome;
merge prior_admit  after7_infect  after30_infect pep7_admit 
	&table._asc_inp3 (in=c rename=(endo_admit7_infection=infect7 endo_admit30_infection=infect30) );
by visitlink endo_daystoevent;
 if c;
if endo_admit7_infection=. and infect7=1 then endo_admit7_infection=1;
if endo_admit7_infection=. then endo_admit7_infection=0;
if endo_admit30_infection=. and infect30=1 then endo_admit30_infection=1;
if endo_admit30_infection=. then endo_admit30_infection=0;
if pep7d_outcome=. then pep7d_outcome=0;
if admit30d_prior=. then admit30d_prior=0;
if endo_medicare=. then endo_medicare=0;
if     endo_age<65 then endo_age_cat=' 0-64';
if 65<=endo_age<75 then endo_age_cat='65-74';
if 75<=endo_age<85 then endo_age_cat='75-84';
if 85<=endo_age<95 then endo_age_cat='85-94';
if 95<=endo_age    then endo_age_cat='95-  ';
if visitlink=. then delete;
run; 
*keep only 1 procedure per patient;
proc sort data=endo_ercp_outcome nodupkey; by visitlink; run;

*assign 20% to infected scope;
DATA random2 (keep = infected_scope);    
DO i=1 to 24000;   *n should match/be greater than n from final dataset;   
x = UNIFORM(123456);      
IF x>.2 THEN infected_scope = 0;        ELSE infected_scope = 1;      
OUTPUT;    END;  
RUN;     PROC FREQ DATA=random2;    table infected_scope;  RUN; 
proc print data=random2 (obs=10); run; 

data &lib..endo_ercp_outcome;
merge endo_ercp_outcome random2;
state="&table";
if visitlink=. then delete;
run;
proc freq data=&lib..endo_ercp_outcome; 
table infected_scope; run;

proc contents data=&table._asc_inp; run;*this is ercp elig table prior to chronic cond;
%mend;
title 'FL';
%statecalc(lib=fl2017, table=FL);
title 'GA';
%statecalc(lib=ga2017, table=GA);
title 'IA';
%statecalc(lib=ia2017, table=IA);
title 'MD';
%statecalc(lib=md2017, table=MD);
title 'WI';
%statecalc(lib=wi2017, table=WI);
*bring all states together;

/*for appendix table start;
proc sort data=wi2017.endo_ercp_outcome nodupkey; by visitlink; run;
 proc freq data=wi2017.endo_ercp_outcome;
 table endo_setting*endo_admit7_infection;
 run;
 proc freq data=wi2017.endo_ercp_outcome;
 where endo_medicare=1;
 table endo_setting*endo_admit7_infection;
 run;
  proc freq data=wi2017.endo_ercp_outcome;
 where endo_cancer_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
 proc freq data=wi2017.endo_ercp_outcome;
 where endo_panc_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
 proc freq data=wi2017.endo_ercp_outcome;
 where endo_cancer_at_proc=1 and endo_panc_at_proc=1;
 table endo_setting*endo_admit7_infection;
 run;
proc freq data=wi2017.endo_ercp_outcome;
 where admit30d_prior=1;
 table endo_setting*endo_admit7_infection;
 run;

 *for appendix table stop;*/

proc contents data=md2017.MD_SIDC_2017_CORE; run;
proc contents data=md2017.MD_SASDC_2017_CORE; run;

data states (drop = endo_daystoevent endo_dt);
set md2017.endo_ercp_outcome
	fl2017.endo_ercp_outcome
	ga2017.endo_ercp_outcome
	ia2017.endo_ercp_outcome
	wi2017.endo_ercp_outcome
;
if tot_grp=0 then 	   cc_cat=0;
if 1<=tot_grp<=5 then   cc_cat=1;
if 6<=tot_grp<=10 then  cc_cat=2;
if 11<=tot_grp<=15 then cc_cat=3;
if 16<=tot_grp     then cc_cat=4;
if tot_grp=. 	  then cc_cat=0;
if endo_bene_race_cd=. then delete;
if infected_scope=. then infected_scope=0;
if endo_panc_at_proc=. then endo_panc_at_proc=0;
if endo_admit365_any=. then endo_admit365_any=0;
if  endo_admit7_any=. then  endo_admit7_any=0;
if  endo_admit7_aspiration=. then endo_admit7_aspiration=0;
if  endo_admit7_ibd=. then  endo_admit7_ibd=0;
if endo_cancer_at_proc=. then endo_cancer_at_proc=0;
if  endo_ibd_at_proc=. then  endo_ibd_at_proc=0;
run;
proc freq data=states; table endo_setting*endo_admit7_infection endo_medicare*endo_admit7_infection elective endo: ; run;

*only keep 1 outcome per endo date by sorting no dup by endo date--DO this before each outcome model
	otherwise will not capture all unique outcome types;
	/*proc sort data=endo_ercp_outcome1 nodupkey; by bene_id endo_dt ; run;*/
%macro outcomepercent(outcome=);
proc sort data=states nodupkey out=calcpercent; by visitlink &outcome; run;
proc freq data=calcpercent;
table  &outcome  elective*&outcome endo_medicare*&outcome;
run;
%mend;
%outcomepercent(outcome=endo_admit7_infection);
%outcomepercent(outcome=endo_admit30_infection);
*%outcomepercent(outcome=admit7d_outcome);
*%outcomepercent(outcome=admit30d_outcome);
%outcomepercent(outcome=pep7d_outcome);

*table 1;
*1	White
2	Black
3	Hispanic
4	Asian or Pacific Islander
5	Native American
6	Other;
proc freq data=states; where endo_admit7_infection=1;
table infected_scope state admit30d_prior endo_age_cat endo_bene_race_cd endo_gndr_cd 
endo_year endo_setting tot_grp cc_cat 
endo_cancer_at_proc endo_panc_at_proc
endo_medicare/*pay1 endo_:*/; run;
proc freq data=states; table endo_admit7_infection; run;
proc means data=states n mean median; var endo_age tot_grp; run;

*table 1 to match medicare;
%macro groupfreqs(group=, var=);
*ods trace on;
ods output onewayfreqs =&var;
proc freq data=states; *where endo_admit7_infection=0; 
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
*if frequency<11 then frequency=.;
*if cumfrequency<11 then cumfrequency=.;
run;
%mend;
%groupfreqs(group="all", var=endo_year); *group should match where clause--enter where clause manually;
%groupfreqs(group="all", var=endo_age_cat);
%groupfreqs(group="all", var=endo_gndr_cd);
%groupfreqs(group="all", var=endo_bene_race_cd );
%groupfreqs(group="all", var=elective);
*%groupfreqs(group="all", var=ed);
%groupfreqs(group="all", var=admit30d_prior);
%groupfreqs(group="all", var=endo_cancer_at_proc );
%groupfreqs(group="all", var=endo_panc_at_proc);
%groupfreqs(group="all", var=endo_infect_at_proc);
%groupfreqs(group="all", var=endo_PEP_at_proc);
%groupfreqs(group="all", var=cc_cat);
*%groupfreqs(group="all", var=endo_NCH_CLM_TYPE_CD);
%groupfreqs(group="all", var=endo_medicare);
%groupfreqs(group="all", var=endo_setting);
*%groupfreqs(group="all", var=inpatient);
%groupfreqs(group="all", var=infected_scope);
*%groupfreqs(group="all", var=endo_c1748);
%groupfreqs(group="all", var=endo_admit7_infection);
%groupfreqs(group="all", var=endo_admit30_infection);
*%groupfreqs(group="all", var=admit7d_outcome);
*%groupfreqs(group="all", var=admit30d_outcome);
%groupfreqs(group="all", var=pep7d_outcome);
*output to a single table and request out;
data all; 
set endo_year endo_age_cat endo_gndr_cd endo_bene_race_cd 
elective /*ed*/ admit30d_prior
endo_cancer_at_proc endo_panc_at_proc endo_infect_at_proc endo_PEP_at_proc
cc_cat /*endo_NCH_CLM_TYPE_CD*/ endo_medicare endo_setting /*inpatient*/  infected_scope /*endo_c1748*/
 endo_admit7_infection
endo_admit30_infection
/*admit7d_outcome
admit30d_outcome*/
pep7d_outcome
;
run;
*get Ns for groups that you made above for;
proc freq data=states;
table endo_admit7_infection endo_admit30_infection endo_setting;
run;
*model to match medicare;
ods output  parameterestimates=_pe
			oddsratios=_or;
proc logistic data=states;
class  	endo_age_cat(ref='65-74') endo_bene_race_cd(ref='1') 
		endo_gndr_cd(ref='1') /*endo_year(ref='2015') */
		admit30d_prior(ref='0') cc_cat(ref='0') elective(ref='1')
		endo_cancer_at_proc(ref='0') endo_panc_at_proc(ref='0') endo_infect_at_proc(ref='0')
		/*infected_scope(ref='0')*/ / param=glm;
model endo_admit30_infection (event='1') = 
			 endo_age_cat endo_bene_race_cd endo_gndr_cd /*endo_year*/ admit30d_prior cc_cat /*endo_c1748*/
			endo_cancer_at_proc endo_panc_at_proc endo_infect_at_proc elective endo_medicare; 
		*ods output parameterestimates=parameterestimates;
         *lsmeans endo_age_cat / e ilink;
         *store out=log_endo_age_cat;
         run;
ods output close;


* p0 calculation;
proc freq data=states; where endo_year=2017;
table endo_admit7_infection; run;

proc freq data=states; where endo_gndr_cd=0;
table endo_admit7_infection; run;
proc freq data=states; where endo_gndr_cd=1;
table endo_admit7_infection; run;

proc freq data=states; where endo_age_cat=' 0-64';
table endo_admit7_infection; run;
proc freq data=states; where endo_age_cat='65-74';
table endo_admit7_infection; run;
proc freq data=states; where endo_age_cat='75-84';
table endo_admit7_infection; run;
proc freq data=states; where endo_age_cat='85-94';
table endo_admit7_infection; run;
proc freq data=states; where endo_age_cat='95-  ';
table endo_admit7_infection; run;

proc freq data=states; where endo_bene_race_cd=1;
table endo_admit7_infection; run;
proc freq data=states; where endo_bene_race_cd=2;
table endo_admit7_infection; run;
proc freq data=states; where endo_bene_race_cd=3;
table endo_admit7_infection; run;
proc freq data=states; where endo_bene_race_cd=4;
table endo_admit7_infection; run;
proc freq data=states; where endo_bene_race_cd=5;
table endo_admit7_infection; run;
proc freq data=states; where endo_bene_race_cd=6;
table endo_admit7_infection; run;

proc freq data=states; where admit30d_prior=1;
table endo_admit7_infection; run;

proc freq data=states; where cc_cat=0;
table endo_admit7_infection; run;
proc freq data=states; where cc_cat=1;
table endo_admit7_infection; run;
proc freq data=states; where cc_cat=2;
table endo_admit7_infection; run;
proc freq data=states; where cc_cat=3;
table endo_admit7_infection; run;
proc freq data=states; where cc_cat=4;
table endo_admit7_infection; run;

*attributable fraction: https://support.sas.com/kb/63/471.html;
proc logistic data=states;
class infected_scope(ref='0') admit30d_prior(ref='0') endo_age_cat(ref='65-74') 
endo_bene_race_cd(ref='1') endo_gndr_cd(ref='1') cc_cat(ref='0') /*pay1(ref='1')*/
endo_cancer_at_proc(ref='0') endo_panc_at_proc(ref='0') endo_medicare(ref='0')/ param=glm;
model endo_admit7_infection (event='1') = 
			  	endo_age_cat endo_gndr_cd   endo_bene_race_cd
				admit30d_prior endo_cancer_at_proc endo_panc_at_proc 
				cc_cat endo_medicare /*pay1*/
			 ;* infected_scope ;
         *lsmeans admit30d_prior / e ilink;
         *store out=log;
         run;
proc freq data=states; 
         table admit30d_prior; *get observed value;
         run;
 /*data fd; 
         length label f $32767; 
         infile datalines delimiter=',';
         input label f; 
         datalines;
      Risk(E)  , logistic(B_p1*B_p2+B_p+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24)
      Risk(NE) , logistic(B_p1*     B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24)
      OR (Expose) , exp(B_p2)
      ARE ,( logistic(B_p1*B_p2+B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) - logistic(B_p1*     B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) ) / ( logistic(B_p1*B_p2+B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) )
      PAR , 0.135*( logistic(B_p1*B_p2+B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) - logistic(B_p1*   B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) ) / ( logistic(B_p1*B_p2+B_p3+B_p4+B_p5+B_p7+B_p8+B_p9+B_p10+B_p11+B_p12+B_p13+B_p14+B_p15+B_p17+B_p18+B_p20+B_p21+B_p22+B_p23+B_p24) )
      ARE OR , (exp(B_p2)-1)/exp(B_p2)
      PAR OR , 0.135*(exp(B_p2)-1)/exp(B_p2)
      ;
run; 
      %NLEstimate( instore=log, fdata=fd );
