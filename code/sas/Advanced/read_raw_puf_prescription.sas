/********************************************************************
* Job Name: read_raw_puf_prescription.sas
* Job Desc: code to read raw txt which is puf prescription sample
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

%global  raw_data_path     ;
%global  raw_data_product  ;
%global  raw_product       ;
%let     raw_data_path     = C:\z_data\z_client_jhu\puf1\;
%let     raw_data_product  =DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv ;
%let     raw_product       = &raw_data_path.&raw_data_product;

%global  perm_lib          ;
%global  lwork             ;
%global  out_ds            ;
%let     perm_lib          =ndcprod        ;
%let     lwork             =work           ;
%let     out_ds            =pat_prescript  ;

%global  pat_id   ;
%global  clm_id   ;
%global  srvc_dt  ;

%let     pat_id   =desynpuf_id  ;
%let     clm_id   =pde_id       ;
%let     srvc_dt  =srvc_dt      ;
%let     prod_id  =prod_srvc_id ;


%macro read_in_raw_to_get_sasds(raw_in_data   = ,
                                local_out_ds  =
                                );
   data &local_out_ds ;
       infile "&raw_in_data"
       delimiter=',' MISSOVER DSD lrecl=32767 firstobs=2 ;

       informat &pat_id                  $42. ; format &pat_id                  $42. ;
       informat &clm_id                  $42. ; format &clm_id                  $42. ;
       informat &srvc_dt          anydtdte21. ; format &srvc_dt            yymmdd10. ;
       informat &prod_id                 $16. ; format &prod_id                 $16. ;
       informat qty_dspnsd_num        best32. ; format qty_dspnsd_num       comma12.0;
       informat days_suply_num        best32. ; format days_suply_num       comma12.0;
       informat ptnt_pay_amt          best32. ; format ptnt_pay_amt         comma12.0;
       informat tot_rx_cst_amt        best32. ; format tot_rx_cst_amt       comma12.0;
    input
                &pat_id                $
                &clm_id                $
                &srvc_dt
                &prod_id               $
                qty_dspnsd_num
                days_suply_num
                ptnt_pay_amt
                tot_rx_cst_amt
    ;
    if &prod_id   in : ("OTHER",'other') then delete;
    run;

%mend; *** end of read_in_raw_to_get_sasds ;


%read_in_raw_to_get_sasds(raw_in_data   = &raw_product,
                          local_out_ds  = &perm_lib..&out_ds
                          );



data &perm_lib..&out_ds   ;
        set &perm_lib..&out_ds    ;
            drop qty_:;
            drop ptnt:;
            drop days_:;
            drop tot_:;
            temp_id=&prod_id *1;
run;

proc sort data= &perm_lib..&out_ds    ;
    by temp_id &srvc_dt ;
run;
