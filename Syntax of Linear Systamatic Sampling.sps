* Encoding: UTF-8.
SET FILTER OFF.
USE ALL.
SPLIT FILE OFF.
EXECUTE.

* Step 0: Open your full population dataset.
GET FILE='C:\Users\SOSU\Documents\PLFS 2023-24\final_popu_data.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.
EXECUTE.

* Step 1: Assign sequential case numbers.
COMPUTE caseno = $CASENUM.
EXECUTE.

* Step 2: Define total N and sample size n.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /N_total = N.
COMPUTE desired_n = 25.
EXECUTE.

* Step 3: Set interval (k = 10).
COMPUTE k = 10.
EXECUTE.

* Step 4: FIXED starting point (reproducible).
COMPUTE start = 3.
EXECUTE.

* Step 5: Flag selected cases — every kth after start.
COMPUTE select = 0.
IF (MOD(caseno - start, k) = 0) select = 1.
EXECUTE.

* Step 6: Verify number of selected cases.
AGGREGATE /OUTFILE=* MODE=ADDVARIABLES /sel_count = SUM(select).
FREQUENCIES VARIABLES=start k sel_count select /FORMAT=NOTABLE.
EXECUTE.

* Step 7: Create new dataset with selected cases only.
DATASET DECLARE Sample25.
DATASET ACTIVATE DataSet1.
SELECT IF (select = 1).
SORT CASES BY caseno.
DATASET COPY Sample25.
DATASET ACTIVATE Sample25.

* Step 8: Save selected sample to new file.
SAVE OUTFILE='C:\Users\SOSU\Documents\PLFS 2023-24\systematic_sampling.sav'
  /COMPRESSED.
EXECUTE.

* Step 9: Verify saved sample (should be 25 cases spaced by 10).
FREQUENCIES VARIABLES=caseno /FORMAT=NOTABLE.
EXECUTE.

* =============================================================
* END — Fixed start = 5 ensures reproducible 25-case sample.
* Selected cases: 5, 15, 25, 35, ..., 245, 255 (up to N=253).
* =============================================================



