* Encoding: UTF-8.
*--------------------------------------------------------------------*
* SRSWR sampling: N = 253, n = 25
* Keeps all original variables from final_popu_data.sav
*--------------------------------------------------------------------*.

*--- Step 1: Open population data and assign unique ID ---*.
GET FILE="C:\Users\SOSU\Documents\PLFS 2023-24\final_popu_data.sav".
DATASET NAME Population WINDOW=FRONT.

* If ID variable doesn’t exist, create it *.
COMPUTE ID = $CASENUM.
EXECUTE.

SORT CASES BY ID.
EXECUTE.

*--------------------------------------------------------------------*
*--- Step 2: Create a dataset with 25 random draws (WITH replacement) ---*.
*--------------------------------------------------------------------*.

DATASET DECLARE Draws.

INPUT PROGRAM.
  LOOP #i = 1 TO 25.
    COMPUTE ID = TRUNC(RV.UNIFORM(1,253.9999)).   /* Random ID between 1–253 */
    COMPUTE Draw_No = #i.                         /* Serial number of draw */
    END CASE.
  END LOOP.
END FILE.
END INPUT PROGRAM.
DATASET NAME Draws WINDOW=FRONT.
EXECUTE.

SORT CASES BY ID.
EXECUTE.

*--------------------------------------------------------------------*
*--- Step 3: Merge random draws with population (SRSWR result) ---*.
*--------------------------------------------------------------------*.

MATCH FILES
  /FILE=Draws
  /TABLE=Population
  /BY ID.
EXECUTE.

DATASET NAME Final_SRSWR WINDOW=FRONT.

*--------------------------------------------------------------------*
*--- Step 4: Keep the required variables ---*.
*--------------------------------------------------------------------*.

MATCH FILES /FILE=* /KEEP=
  Draw_No
  ID
  hhid
  Sample_Serial_number
  Social_group
  Household_Size
  Household_Usual_Consumer_Expenditure_Month
  HouseholdsAnnualExpenditureonpurchaseofitemslikeclothingfootwear
  education_level.
EXECUTE.

*--------------------------------------------------------------------*
*--- Step 5: Verify results ---*.
*--------------------------------------------------------------------*.

* Should show 25 cases (duplicates allowed) *.
FREQUENCIES VARIABLES=ID /ORDER=ANALYSIS.

* Optional: view final sample *.
LIST ID Draw_No hhid Social_group Household_Size.

