*Goal add in Elixhauser comorbidity score for icd-10;
*http://mchp-appserv.cpe.umanitoba.ca/Upload/SAS/_ElixhauserICD10.sas.txt;
*this program has been edited from the web version to remove dxtype;

/*  This is the Elixhauser Comorbidity Index macro code using ICD-10-CA

    This program reads through the diagnosis codes of patient abstract records in a hospital
    file and identifies whether the record belongs to one or more of 31 different
    Elixhauser Comorbdity (ELX) groups.  The groups are identified by using the ICD-10
    diagnosis codes listed in Quan et al., "Coding Algorithms for Defining Comorbidities
    in ICD-9-CM and ICD-10 Administrative Data", Medical Care:43(11), Nov. 2005 p1130-1139.

    The original SAS code for this program was developed by Hude Quan's group at the U of C
    in Calgary, and modified to work with MCHP data.

    The diagnosis codes match on either 3, 4, 5 or 6 digits, as described in the article.
    All 25 diagnosis and diagnosis type fields are reviewed.

    Diagnosis codes are checked with the IN: statement at the 3, 4, 5, or 6th digit level.
    Diagnoses are excluded if the diagnosis type (DXTYPE##) = '2' (post-admit comorbidity - a
    condition arising after admission).

    Date:  May 11, 2006
    Author: Ken Turner & Charles Burchill
    File Name: /home/kturner/comorbidity/elixhausern/ElixhauserICD10_macro.sas
*/

%macro _ElixhauserICD10 (DATA      =,    /* input data set */
                         OUT =,    /* output data set */
                         dx = /*diag01-diag25,  /* range of diagnosis variables (diag01-diag25) */
							) ;
	%put Elixhauser Comorbidity Index Macro - ICD10 Codes ;
	%put Manitoba Centre for Health Policy, Based on Code from Hude Quan University of Calgary ;
	%put Quan et al., Coding Algorithms for Defining Comorbidities ;
	%put     in ICD-9-CM and ICD-10 Administrative Data, Medical Care:43(11), Nov. 2005 p1130-1139 ;
	%put Version 1.0e  February 23, 2007 ;

    data &OUT;
    set &DATA  ;

    /*  set up array for individual ELX group counters */
    array ELX_GRP (31) ELX_GRP_1 - ELX_GRP_31;

    /*  set up array for each diagnosis code within a record */
    array DX (*) &dx;

    /*  initialize all ELX group counters to zero */
    do i = 1 to 31;
       ELX_GRP(i) = 0;
    end;

    /*  check each set of diagnoses codes for each ELX group. */

    do i = 1 to dim(dx) UNTIL (DX(i)=' ');   /* for each set of diagnoses codes */

  /* identify ELX group */

          /* Congestive Heart Failure */
          if  DX(i) IN:  ('I099','I110','I130','I132','I255','I420','I425','I426','I427','I428',
                          'I429','I43','I50','P290') then ELX_GRP_1 = 1;
            LABEL ELX_GRP_1 = 'Congestive Heart Failure';


          /*Caridiac Arrhythmia*/
          if  DX(i) IN:  ('I441','I442','I443','I456','I459','I47','I48','I49','R000','R001',
                          'R008','T821','Z450','Z950') then ELX_GRP_2 = 1;
            LABEL ELX_GRP_2 = 'Caridiac Arrhythmia';

          /*Valvular Disease*/
          if  DX(i) IN:  ('A520','I05','I06','I07','I08','I091','I098','I34','I35','I36','I37',
                          'I38','I39','Q230','Q231','Q232','Q233','Z952','Z953','Z954')
                          then ELX_GRP_3 = 1;
            LABEL ELX_GRP_3 = 'Valvular Disease';

          /*Pulmonary Circulation Disorders*/
          if  DX(i) IN:  ('I26','I27','I280','I288','I289') then ELX_GRP_4 = 1;
            LABEL ELX_GRP_4 = 'Pulmonary Circulation Disorders';

          /*Peripheral Vascular Disorders*/
          if  DX(i) IN:  ('I70','I71','I731','I738','I739','I771','I790','I792','K551','K558',
                          'K559','Z958','Z959') then ELX_GRP_5 = 1;
            LABEL ELX_GRP_5 = 'Peripheral Vascular Disorders';

          /*Hypertension Uncomlicated*/
          if  DX(i) IN:  ('I10') then ELX_GRP_6 = 1;
            LABEL ELX_GRP_6 = 'Hypertension Uncomplicated';

          /*Hypertension comlicated*/
          if  DX(i) IN:  ('I11','I12','I13','I15') then ELX_GRP_7 = 1;
            LABEL ELX_GRP_7 ='Hypertension Complicated';

          /*Paralysis*/
          if  DX(i) IN:  ('G041','G114','G801','G802','G81','G82','G830','G831','G832','G833',
                          'G834','G839') then ELX_GRP_8 = 1;
            LABEL ELX_GRP_8 = 'Paralysis';

          /* Other Neurological Disorders*/
          if  DX(i) IN:  ('G10','G11','G12','G13','G20','G21','G22','G254','G255','G312','G318',
                          'G319','G32','G35','G36','G37','G40','G41','G931','G934','R470','R56')
                          then ELX_GRP_9 = 1;
            LABEL ELX_GRP_9 = 'Other Neurological Disorders';

          /*Chronic Pulmonary Disease*/
          if  DX(i) IN:  ('I278','I279','J40','J41','J42','J43','J44','J45','J46','J47','J60','J61',
                          'J62','J63','J64','J65','J66','J67','J684','J701','J703')
                          then ELX_GRP_10 = 1;
            LABEL ELX_GRP_10 = 'Chronic Pulmonary Disease';

          /*Diabetes Uncomplicated*/
          if  DX(i) IN:  ('E100','E101','E109','E110','E111','E119','E120','E121','E129','E130',
                          'E131','E139','E140','E141','E149') then ELX_GRP_11 = 1;
            LABEL ELX_GRP_11 = 'Diabetes Uncomplicated';

          /*Diabetes Complicated*/
          if  DX(i) IN:  ('E102','E103','E104','E105','E106','E107','E108','E112','E113','E114','E115',
                          'E116','E117','E118','E122','E123','E124','E125','E126','E127','E128','E132',
                          'E133','E134','E135','E136','E137','E138','E142','E143','E144','E145','E146',
                          'E147','E148') then ELX_GRP_12 = 1;
            LABEL ELX_GRP_12 = 'Diabetes Complicated';

          /*Hypothyroidism*/
          if  DX(i) IN:  ('E00','E01','E02','E03','E890') then ELX_GRP_13 = 1;
            LABEL ELX_GRP_13 = 'Hypothyroidism';

          /*Renal Failure*/
          if  DX(i) IN:  ('I120','I131','N18','N19','N250','Z490','Z491','Z492','Z940','Z992')
                          then ELX_GRP_14 = 1;
            LABEL ELX_GRP_14 = 'Renal Failure';

          /*Liver Disease*/
          if  DX(i) IN:  ('B18','I85','I864','I982','K70','K711','K713','K714','K715','K717','K72','K73',
                          'K74','K760','K762','K763','K764','K765','K766','K767','K768','K769','Z944')
                          then ELX_GRP_15 = 1;
            LABEL ELX_GRP_15 = 'Liver Disease';

          /*Peptic Ulcer Disease excluding bleeding*/
          if  DX(i) IN:  ('K257','K259','K267','K269','K277','K279','K287','K289') then ELX_GRP_16 = 1;
            LABEL ELX_GRP_16 = 'Peptic Ulcer Disease excluding bleeding';

          /*AIDS/HIV*/
          if  DX(i) IN:  ('B20','B21','B22','B24') then ELX_GRP_17 = 1;
            LABEL ELX_GRP_17 = 'AIDS/HIV';

          /*Lymphoma*/
          if  DX(i) IN:  ('C81','C82','C83','C84','C85','C88','C96','C900','C902') then ELX_GRP_18 = 1;
            LABEL ELX_GRP_18 = 'Lymphoma';

          /*Metastatic Cancer*/
          if  DX(i) IN:  ('C77','C78','C79','C80') then ELX_GRP_19 = 1;
            LABEL ELX_GRP_19 ='Metastatic Cancer';

          /*Solid Tumor without Metastasis*/
          if  DX(i) IN:  ('C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11','C12','C13',
                          'C14','C15','C16','C17','C18','C19','C20','C21','C22','C23','C24','C25','C26','C30',
                          'C31','C32','C33','C34','C37','C38','C39','C40','C41','C43','C45','C46','C47','C48',
                          'C49','C50','C51','C52','C53','C54','C55','C56','C57','C58','C60','C61','C62','C63',
                          'C64','C65','C66','C67','C68','C69','C70','C71','C72','C73','C74','C75','C76','C97')
                          then ELX_GRP_20 = 1;
            LABEL ELX_GRP_20 = 'Solid Tumor without Metastasis';

          /*Rheumatoid Arthritis/collagen*/
          if  DX(i) IN:  ('L940','L941','L943','M05','M06','M08','M120','M123','M30','M310','M311','M312','M313',
                          'M32','M33','M34','M35','M45','M461','M468','M469') then ELX_GRP_21 = 1;
            LABEL ELX_GRP_21 = 'Rheumatoid Arthritis/collagen';

          /*Coagulopathy*/
          if  DX(i) IN:  ('D65','D66','D67','D68','D691','D693','D694','D695','D696') then ELX_GRP_22 = 1;
            LABEL ELX_GRP_22 = 'Coagulopathy';

          /*Obesity*/
          if  DX(i) IN:  ('E66') then ELX_GRP_23 = 1;
            LABEL ELX_GRP_23 = 'Obesity';

          /*Weight Loss*/
          if  DX(i) IN:  ('E40','E41','E42','E43','E44','E45','E46','R634','R64') then ELX_GRP_24 = 1;
            LABEL ELX_GRP_24 = 'Weight Loss';

          /*Fluid and Electrolyte Disorders*/
          if  DX(i) IN:  ('E222','E86','E87') then ELX_GRP_25 = 1;
            LABEL ELX_GRP_25 = 'Fluid and Electrolyte Disorders';

          /*Blood Loss Anemia*/
          if  DX(i) IN:  ('D500') then ELX_GRP_26 = 1;
            LABEL ELX_GRP_26 = 'Blood Loss Anemia';

          /*Deficiency Anemia*/
          if  DX(i) IN:  ('D508','D509','D51','D52','D53') then ELX_GRP_27 = 1;
            LABEL ELX_GRP_27 = 'Deficiency Anemia';

          /*Alcohol Abuse*/
          if  DX(i) IN:  ('F10','E52','G621','I426','K292','K700','K703','K709','T51','Z502','Z714','Z721')
                          then ELX_GRP_28 = 1;
            LABEL ELX_GRP_28 = 'Alcohol Abuse';

          /*Drug Abuse*/
          if  DX(i) IN:  ('F11','F12','F13','F14','F15','F16','F18','F19','Z715','Z722') then ELX_GRP_29 = 1;
            LABEL ELX_GRP_29 = 'Drug Abuse';

          /*Psychoses*/
          if  DX(i) IN:  ('F20','F22','F23','F24','F25','F28','F29','F302','F312','F315') then ELX_GRP_30 = 1;
            LABEL ELX_GRP_30 = 'Psychoses';

          /*Depression*/
          if  DX(i) IN:  ('F204','F313','F314','F315','F32','F33','F341','F412','F432') then ELX_GRP_31 = 1;
            LABEL ELX_GRP_31 = 'Depression';			
    end;

    TOT_GRP = ELX_GRP_1  + ELX_GRP_2  +  ELX_GRP_3  +  ELX_GRP_4  +  ELX_GRP_5  +  ELX_GRP_6  +  ELX_GRP_7  +
              ELX_GRP_8  + ELX_GRP_9  +  ELX_GRP_10 +  ELX_GRP_11 +  ELX_GRP_12 +  ELX_GRP_13 +  ELX_GRP_14 +
              ELX_GRP_15 + ELX_GRP_16 +  ELX_GRP_17 +  ELX_GRP_18 +  ELX_GRP_19 +  ELX_GRP_20 +  ELX_GRP_21 +
              ELX_GRP_22 + ELX_GRP_23 +  ELX_GRP_24 +  ELX_GRP_25 +  ELX_GRP_26 +  ELX_GRP_27 +  ELX_GRP_28 +
              ELX_GRP_29 + ELX_GRP_30 +  ELX_GRP_31;
     LABEL TOT_GRP='Total Elixhauser Groups per record';

	run;
    
%mend _ElixhauserICD10;


/****************  Example Program Code ****************
data hosp_0405;
   set cpe8.hsp0405(obs=10000);
run;

   * macro call *;
   
   %_ElixhauserICD10 (DATA     =hosp_0405,
                      OUT      =ELX_groups,
                      dx       =diag01-diag25,
                      dxtype   =diagtype01-diagtype25);



**************************************************
*  Analysis Section of program                   *
**************************************************;


PROC FREQ data=ELX_groups;
   TITLE1  "Elixhauser Comorbidity Groups, Excluding Diagnosis Type of";
   TITLE2  "'Condition Arising After Beginning of Hospital Observation or Treatment'";
   TITLE3  "Using ICD-10-CA Coding";
   TABLES  ELX_GRP: TOT_GRP;
RUN;

****/
