/********************************************************************
* Job Name: read_raw_puf_beneficiary_data.sas
* Job Desc: code to read raw txt which is puf prescription sample
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

%global  raw_data_path     ;
%global  raw_data_product  ;
%global  perm_lib          ;
%global  lwork             ;
%let     perm_lib          =synth          ;
%let     lwork             =work           ;

libname &perm_lib "C:\z_data\z_client_jhu\puf1";

%global  pat_id   ;
%let     pat_id   =desynpuf_id  ;

%macro read_in_raw_to_get_sasds(raw_in_data   = ,
                                local_out_ds  =
                                );
   data &local_out_ds ;
       infile "&raw_in_data"
       delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
       informat &pat_id                   $42.       ; format &pat_id                   $42.       ;
       informat bene_birth_dt             anydtdte21.; format bene_birth_dt             yymmdd10.  ;
       informat bene_death_dt             anydtdte21.; format bene_death_dt             yymmdd10.  ;
       informat bene_sex_ident_cd         $1.        ; format bene_sex_ident_cd         $1.        ;
       informat bene_race_cd              $1.        ; format bene_race_cd              $1.        ;
       informat bene_esrd_ind             $1.        ; format bene_esrd_ind             $1.        ;
       informat sp_state_code             $2.        ; format sp_state_code             $2.        ;
       informat bene_county_cd            $3.        ; format bene_county_cd            $3.        ;
       informat bene_hi_cvrage_tot_mons   best32.    ; format bene_hi_cvrage_tot_mons   best32.    ;
       informat bene_smi_cvrage_tot_mons  best32.    ; format bene_smi_cvrage_tot_mons  best32.    ;
       informat bene_hmo_cvrage_tot_mons  best32.    ; format bene_hmo_cvrage_tot_mons  best32.    ;
       informat plan_cvrg_mos_num         best32.    ; format plan_cvrg_mos_num         best32.    ;
       informat sp_alzhdmta               best32.    ; format sp_alzhdmta               best32.    ;
       informat sp_chf                    best32.    ; format sp_chf                    best32.    ;
       informat sp_chrnkidn               best32.    ; format sp_chrnkidn               best32.    ;
       informat sp_cncr                   best32.    ; format sp_cncr                   best32.    ;
       informat sp_copd                   best32.    ; format sp_copd                   best32.    ;
       informat sp_depressn               best32.    ; format sp_depressn               best32.    ;
       informat sp_diabetes               best32.    ; format sp_diabetes               best32.    ;
       informat sp_ischmcht               best32.    ; format sp_ischmcht               best32.    ;
       informat sp_osteoprs               best32.    ; format sp_osteoprs               best32.    ;
       informat sp_ra_oa                  best32.    ; format sp_ra_oa                  best32.    ;
       informat sp_strketia               best32.    ; format sp_strketia               best32.    ;
       informat medreimb_ip               best32.    ; format medreimb_ip               best32.    ;
       informat benres_ip                 best32.    ; format benres_ip                 best32.    ;
       informat pppymt_ip                 best32.    ; format pppymt_ip                 best32.    ;
       informat medreimb_op               best32.    ; format medreimb_op               best32.    ;
       informat benres_op                 best32.    ; format benres_op                 best32.    ;
       informat pppymt_op                 best32.    ; format pppymt_op                 best32.    ;
       informat medreimb_car              best32.    ; format medreimb_car              best32.    ;
       informat benres_car                best32.    ; format benres_car                best32.    ;
       informat pppymt_car                best32.    ; format pppymt_car                best32.    ;
    input
          &pat_id                   $
          bene_birth_dt
          bene_death_dt
          bene_sex_ident_cd         $
          bene_race_cd              $
          bene_esrd_ind             $
          sp_state_code             $
          bene_county_cd            $
          bene_hi_cvrage_tot_mons
          bene_smi_cvrage_tot_mons
          bene_hmo_cvrage_tot_mons
          plan_cvrg_mos_num
          sp_alzhdmta
          sp_chf
          sp_chrnkidn
          sp_cncr
          sp_copd
          sp_depressn
          sp_diabetes
          sp_ischmcht
          sp_osteoprs
          sp_ra_oa
          sp_strketia
          medreimb_ip
          benres_ip
          pppymt_ip
          medreimb_op
          benres_op
          pppymt_op
          medreimb_car
          benres_car
          pppymt_car
    ;
run;


%mend; *** end of read_in_raw_to_get_sasds ;


%let     raw_data_path     = C:\z_data\z_client_jhu\puf1\;

%let     raw_data_product  = DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv ;
%read_in_raw_to_get_sasds(raw_in_data   = &raw_data_path.&raw_data_product ,
                          local_out_ds  = &perm_lib..Beneficiary_2008_sample_1
                          );

%let     raw_data_product  = DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv ;
%read_in_raw_to_get_sasds(raw_in_data   = &raw_data_path.&raw_data_product ,
                          local_out_ds  = &perm_lib..Beneficiary_2009_sample_1
                          );

%let     raw_data_product  = DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv ;
%read_in_raw_to_get_sasds(raw_in_data   = &raw_data_path.&raw_data_product ,
                          local_out_ds  = &perm_lib..Beneficiary_2010_sample_1
                          );
