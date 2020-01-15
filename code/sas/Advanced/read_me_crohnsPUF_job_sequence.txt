/********************************************************************
* Job Name: read_me_crohnsPUF_job_sequence.txt
* Job Desc: describe the jobs and sequence required to run jobs
		to create a cohort of Crohn's disease patients
		in Medicaid
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************
Seq   Job Name
  0   read_me_crohnsPUF_job_sequence.txt
  0   0_setup_facts.sas
      - this job includes: macro_tool_box.sas
  
  -   if csv data is not in reliable sas data table format see next step(s): 1
  -   if csv data is already in ready, reliable useable sas data go to step(s): 2

Seq   Job Name
  1   Read Raw CSV to build SAS Data Steps
      - these are only if you have a need to refresh, rebuild the sas data from csv
      - these jobs in seq-1 can be run one at a time.
      - these jobs do share field properties and other key elements
 1.1  read_raw_ndc_products.sas
 1.2  read_raw_puf_prescription.sas
 
 1.3  read_raw_puf_beneficiary_data.sas
      - caution with 1.3 - if  you must run this job - do this in a refreshed sas session.
 
 ---  caution before going to next step
      - it is recommended that if you ran any one or more job in SEQ1 - that you:
      - close any open sas session and start a new one for the work in next seq.
      - this is a precaution to ensur that libname, path name, macro variable naming are
        kept only to the purpose of the intentions of the sequence you are working on.


Seq   Job Name
---   caution - before engaging in jobs, work in this step 
      make sure that you:
         a. are on a new sas session
         b. run the 0_setup_facts.sas
  2   NDC Product Scan Steps
      - An analyst needs to define one or more medicine, pharma for process to work better.
      - A default - place holder medicine has been configured to allow this process to work and
                    also allow you to see how to configure other medicine products you wish to
                    explore.
      - You must determine when you are done with the jobs/work/steps in this sequence
                    before its ok to continue to the next sequence.
 2.1  scan_ndc_data_for_products.sas
      - this job uses macro: macro_ndc_char_scan_for_drug_name.sas
      - this job also uses code/data in: \code\definitions\**.txt
          - those are critical to have: a. in existance, b. configured as described
      - you can run this job more than once but must keep track of *.txt and also
        the "med_ndc_pfx" Medical - NDC - Prefix value you assign in this process
        that value is the field/variable prefix which will be used in subsequent steps.
      - the output from this job is used in the next sequence

 ---  caution before going to next step
      - it is recommended that if you ran code in seq 2 that you:
      - close any open sas session and start a new one for the work in next seq.
      - this is a precaution to ensur that libname, path name, macro variable naming are
        kept only to the purpose of the intentions of the sequence you are working on.

Seq   Job Name
  3   Disease Ident on Claims - Merge Denom/PS facts to Claim, Merge NDC Products to Claim
---   caution - before engaging in jobs, work in this step 
      make sure that you:
         a. are on a new sas session
         b. run the 0_setup_facts.sas

 3.1  crohns_claim_identify_denom_elig_merge_ndc_product_merge.sas
      - while under development - this job was also called "validation.."
      - that is name that is no longer relevant.
      - this job takes input(s) like:
        - claim data
        - denominator (mbsf)
        - NDC product output from earlier step
      - identifies "crohns" claims based on project definition
      - merges the data mentioned in this step together