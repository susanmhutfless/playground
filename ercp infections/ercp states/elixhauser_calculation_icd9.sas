*Goal: To add in Elixhauser comorbidity variables in the denominator cohort dataset;
*create elixhauser scores;
*http://mchp-appserv.cpe.umanitoba.ca/Upload/SAS/_ElixhauserICD9CM.sas.txt;
*start;
%macro _ElixhauserICD9CM (DATA    =,   /* input data set */
                           OUT    =,   /* output data set */
                           dx     = /* range of diagnosis variables (dx01-dx16) */
                           ) ;

	
	%put Elixhauser Comorbidity Index Macro - ICD9CM Codes ;
	%put Manitoba Centre for Health Policy, Based on Code from Hude Quan University of Calgary ;
	%put Quan et al., Coding Algorithms for Defining Comorbidities ;
	%put     in ICD-9-CM and ICD-10 Administrative Data, Medical Care:43(11), Nov. 2005 p1130-1139 ;
	%put Version 1.0e February 23, 2007 ;

   data &OUT;
   set &DATA;

   /*  set up array for individual ELX group counters */
   array ELX_GRP (31) ELX_GRP_1 - ELX_GRP_31;

   /*  set up array for each diagnosis code within a record */
   array DX (*) &dx;
   /*  initialize all ELX group counters to zero */
   do i = 1 to 31;
      ELX_GRP(i) = 0;
   end;

   /*  check each patient record for the diagnosis codes in each ELX group. */
   do i = 1 to dim(dx) UNTIL (DX(i)=' ');   /* for each set of diagnoses codes */

   /*  skip diagnosis if diagnosis type = "C" */
        /* identify Elixhauser groupings */

         /* Congestive Heart Failure */
         if  Dx(i) IN: ('39891','40201','40211','40291','40401','40403','40411','40413','40491',
                 '40493','4254','4255','4257','4258','4259','428') then ELX_GRP_1 = 1;
            LABEL ELX_GRP_1='Congestive Heart Failure';

         /* Cardiac Arrhythmia */
         if  Dx(i) IN: ('4260','42613','4267','4269','42610','42612','4270','4271','4272','4273',
                 '4274','4276','4278','4279','7850','99601','99604','V450','V533') then ELX_GRP_2 = 1;
            LABEL ELX_GRP_2='Cardiac Arrhythmia';

         /* Valvular Disease */
         if  Dx(i) IN: ('0932','394','395','396','397','424','7463','7464','7465','7466','V422','V433')
                  then ELX_GRP_3 = 1;
            LABEL ELX_GRP_3='Valvular Disease';

         /* Pulmonary Circulation Disorders */
         if  Dx(i) IN: ('4150','4151','416','4170','4178','4179') then ELX_GRP_4 = 1;
            LABEL ELX_GRP_4='Pulmonary Circulation Disorders';

         /* Peripheral Vascular Disorders */
         if  Dx(i) IN: ('0930','4373','440','441','4431','4432','4438','4439','4471','5571','5579','V434')
                  then ELX_GRP_5 = 1;
            LABEL ELX_GRP_5='Peripheral Vascular Disorders';

         /* Hypertension Uncomplicated */
         if  Dx(i) IN: ('401') then ELX_GRP_6 = 1;
            LABEL ELX_GRP_6='Hypertension Uncomplicated';

         /* Hypertension Complicated */
         if  Dx(i) IN: ('402','403','404','405') then ELX_GRP_7 = 1;
            LABEL ELX_GRP_7='Hypertension Complicated';

         /* Paralysis */
         if  Dx(i) IN: ('3341','342','343','3440','3441','3442','3443','3444','3445','3446','3449')
                  then ELX_GRP_8 = 1;
           LABEL ELX_GRP_8='Paralysis';

         /* Other Neurological Disorders */
         if  Dx(i) IN: ('3319','3320','3321','3334','3335','33392','334','335','3362','340','341',
                  '345','3481','3483','7803','7843') then ELX_GRP_9 = 1;
           LABEL ELX_GRP_9='Other Neurological Disorders';

         /* Chronic Pulmonary Disease */
         if  Dx(i) IN: ('4168','4169','490','491','492','493','494','495','496','500','501','502',
                  '503','504','505','5064','5081','5088') then ELX_GRP_10 = 1;
           LABEL ELX_GRP_10='Chronic Pulmonary Disease';

         /* Diabetes Uncomplicated */
         if  Dx(i) IN: ('2500','2501','2502','2503') then ELX_GRP_11 = 1;
           LABEL ELX_GRP_11='Diabetes Uncomplicated';

         /* Diabetes Complicated */
         if  Dx(i) IN: ('2504','2505','2506','2507','2508','2509') then ELX_GRP_12 = 1;
           LABEL ELX_GRP_12='Diabetes Complicated';

         /* Hypothyroidism */
         if  Dx(i) IN: ('2409','243','244','2461','2468') then ELX_GRP_13 = 1;
           LABEL ELX_GRP_13='Hypothyroidism';

         /* Renal Failure */
         if  Dx(i) IN: ('40301','40311','40391','40402','40403','40412','40413','40492','40493',
                  '585','586','5880','V420','V451','V56') then ELX_GRP_14 = 1;
           LABEL ELX_GRP_14='Renal Failure';

         /* Liver Disease */
         if  Dx(i) IN: ('07022','07023','07032','07033','07044','07054','0706','0709','4560','4561',
                  '4562','570','571','5722','5723','5724','5728','5733','5734','5738','5739','V427')
                  then ELX_GRP_15 = 1;
           LABEL ELX_GRP_15='Liver Disease';

         /* Peptic Ulcer Disease excluding bleeding */
         if  Dx(i) IN: ('5317','5319','5327','5329','5337','5339','5347','5349')
                  then ELX_GRP_16 = 1;
           LABEL ELX_GRP_16='Peptic Ulcer Disease excluding bleeding';

         /* AIDS/HIV */
         if  Dx(i) IN: ('042','043','044')  then ELX_GRP_17 = 1;
           LABEL ELX_GRP_17='AIDS/HIV';

         /* Lymphoma */
         if  Dx(i) IN: ('200','201','202','2030','2386') then ELX_GRP_18 = 1;
           LABEL ELX_GRP_18='Lymphoma';

         /* Metastatic Cancer */
         if  Dx(i) IN: ('196','197','198','199') then ELX_GRP_19 = 1;
           LABEL ELX_GRP_19='Metastatic Cancer';

         /* Solid Tumor without Metastasis */
         if  Dx(i) IN: ('140','141','142','143','144','145','146','147','148','149','150','151','152',
                  '153','154','155','156','157','158','159','160','161','162','163','164','165','166','167',
                  '168','169','170','171','172','174','175','176','177','178','179','180','181','182','183',
                  '184','185','186','187','188','189','190','191','192','193','194','195')
                  then ELX_GRP_20 = 1;
           LABEL ELX_GRP_20='Solid Tumor without Metastasis';

         /* Rheumatoid Arthritis/collagen */
         if  Dx(i) IN: ('446','7010','7100','7101','7102','7103','7104','7108','7109','7112','714',
                  '7193','720','725','7285','72889','72930') then ELX_GRP_21 = 1;
           LABEL ELX_GRP_21='Rheumatoid Arthritis/collagen';

         /* Coagulopathy */
         if  Dx(i) IN: ('286','2871','2873','2874','2875')  then ELX_GRP_22 = 1;
           LABEL ELX_GRP_22='Coagulopathy';

         /* Obesity */
         if  Dx(i) IN: ('2780') then ELX_GRP_23 = 1;
           LABEL ELX_GRP_23='Obesity';

         /* Weight Loss */
         if  Dx(i) IN: ('260','261','262','263','7832','7994') then ELX_GRP_24 = 1;
           LABEL ELX_GRP_24='Weight Loss';

         /* Fluid and Electrolyte Disorders */
         if  Dx(i) IN: ('2536','276') then ELX_GRP_25 = 1;
           LABEL ELX_GRP_25='Fluid and Electrolyte Disorders';

         /* Blood Loss Anemia */
         if  Dx(i) IN: ('2800') then ELX_GRP_26 = 1;
           LABEL ELX_GRP_26='Blood Loss Anemia';

         /* Deficiency Anemia */
         if  Dx(i) IN: ('2801','2808','2809','281') then ELX_GRP_27 = 1;
           LABEL ELX_GRP_27='Deficiency Anemia';

         /* Alcohol Abuse */
         if  Dx(i) IN: ('2652','2911','2912','2913','2915','2918','2919','3030','3039','3050',
                  '3575','4255','5353','5710','5711','5712','5713','980','V113') then ELX_GRP_28 = 1;
           LABEL ELX_GRP_28='Alcohol Abuse';

         /* Drug Abuse */
         if  Dx(i) IN: ('292','304','3052','3053','3054','3055','3056','3057','3058','3059','V6542')
                  then ELX_GRP_29 = 1;
           LABEL ELX_GRP_29='Drug Abuse';

         /* Psychoses */
         if  Dx(i) IN: ('2938','295','29604','29614','29644','29654','297','298')
                  then ELX_GRP_30 = 1;
           LABEL ELX_GRP_30='Psychoses';

         /* Depression */
         if  Dx(i) IN: ('2962','2963','2965','3004','309','311') then ELX_GRP_31 = 1;
           LABEL ELX_GRP_31='Depression';	
   end;


   TOT_GRP = ELX_GRP_1  + ELX_GRP_2  +  ELX_GRP_3  +  ELX_GRP_4  +  ELX_GRP_5  +  ELX_GRP_6  +  ELX_GRP_7  +
             ELX_GRP_8  + ELX_GRP_9  +  ELX_GRP_10 +  ELX_GRP_11 +  ELX_GRP_12 +  ELX_GRP_13 +  ELX_GRP_14 +
             ELX_GRP_15 + ELX_GRP_16 +  ELX_GRP_17 +  ELX_GRP_18 +  ELX_GRP_19 +  ELX_GRP_20 +  ELX_GRP_21 +
             ELX_GRP_22 + ELX_GRP_23 +  ELX_GRP_24 +  ELX_GRP_25 +  ELX_GRP_26 +  ELX_GRP_27 +  ELX_GRP_28 +
             ELX_GRP_29 + ELX_GRP_30 +  ELX_GRP_31;
     LABEL TOT_GRP ='Total Elixhauser Groups per record';
	run;
%mend _ElixhauserICD9CM;
*%_ElixhauserICD9CM (DATA    =GI_endo_cohort_SASD_fl2014_2,
                       OUT     =GI_endo_cohort_SASD_fl2014_ELX,
                       dx      =proc_dx1-proc_dx10) ;
