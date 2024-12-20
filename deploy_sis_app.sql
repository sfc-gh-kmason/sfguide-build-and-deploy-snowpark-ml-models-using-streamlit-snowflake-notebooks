SET major = 1;
SET minor = 0;
SET database_name='ML_SIDEKICK';
SET schema_name=CONCAT($database_name,'.ST_APPS');
SET stage_name=CONCAT($schema_name,'.APP_STG');
SET app_name=CONCAT($schema_name,'.ML_SIDEKICK');
SET (streamlit_warehouse)=(SELECT CURRENT_WAREHOUSE());
SET git_repo=CONCAT($schema_name,'.ML_SIDEKICK_REPO');
SET main_file = 'automl_app.py';
SET COMMENT = concat('{"origin": "sf_sit",
            "name": "ml_sidekick",
            "version": {"major": ',$major,', "minor": ',$minor,'},
            "attributes":{"component":"sis_app"}}');

CREATE DATABASE IF NOT EXISTS IDENTIFIER($database_name)
COMMENT = $COMMENT;

CREATE SCHEMA IF NOT EXISTS IDENTIFIER($schema_name)
COMMENT = $COMMENT;

CREATE STAGE IF NOT EXISTS IDENTIFIER($stage_name)
DIRECTORY = (ENABLE = true)
COMMENT = $COMMENT;


-- Create API Integration for Git
USE SCHEMA IDENTIFIER($schema_name);
CREATE OR REPLACE API INTEGRATION git_api_integration_snowflake_labs
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/Snowflake-Labs')
  ENABLED = TRUE;

-- Create Git Repository
CREATE OR REPLACE GIT REPOSITORY IDENTIFIER($git_repo)
  API_INTEGRATION = git_api_integration_snowflake_labs
  ORIGIN = 'https://github.com/Snowflake-Labs/sfguide-build-and-deploy-snowpark-ml-models-using-streamlit-snowflake-notebooks.git';

ALTER GIT REPOSITORY IDENTIFIER($git_repo) FETCH;

COPY FILES
  INTO @ML_SIDEKICK.ST_APPS.APP_STG
  FROM @ML_SIDEKICK.ST_APPS.ML_SIDEKICK_REPO/branches/main/streamlit-automl/
  PATTERN='.*[.]py';

-- NOTE: SQL variables not permitted in COPY INTO or STREAMLTI ROOT_LOCATION at this time.
COPY FILES
  INTO @ML_SIDEKICK.ST_APPS.APP_STG
  FROM @ML_SIDEKICK.ST_APPS.ML_SIDEKICK_REPO/branches/main/streamlit-automl/
  FILES=('environment.yml');

COPY FILES
  INTO @ML_SIDEKICK.ST_APPS.APP_STG/styles/
  FROM @ML_SIDEKICK.ST_APPS.ML_SIDEKICK_REPO/branches/main/streamlit-automl/styles/
  FILES=('css_bootstrap.html');

COPY FILES
  INTO @ML_SIDEKICK.ST_APPS.APP_STG/resources/
  FROM @ML_SIDEKICK.ST_APPS.ML_SIDEKICK_REPO/branches/main/streamlit-automl/resources/;

CREATE OR REPLACE STREAMLIT IDENTIFIER($app_name)
ROOT_LOCATION = '@ML_SIDEKICK.ST_APPS.APP_STG'
MAIN_FILE = $main_file
QUERY_WAREHOUSE = $streamlit_warehouse
COMMENT = $COMMENT;

CREATE OR REPLACE SCHEMA TEST_DATA;

CREATE OR REPLACE TABLE ML_SIDEKICK.TEST_DATA.ABALONE
(
SEX VARCHAR,
LENGTH NUMBER,
DIAMETER NUMBER,
HEIGHT NUMBER,
WHOLE_WEIGHT NUMBER,
SHUCKED_WEIGHT NUMBER,
VISCERA_WEIGHT NUMBER,
SHELL_WEIGHT NUMBER,
RINGS INTEGER
);

-- create diabetes table
CREATE OR REPLACE TABLE ML_SIDEKICK.TEST_DATA.DIABETES
(
Diabetes_binary INTEGER,
HighBP INTEGER,
HighChol INTEGER,
CholCheck INTEGER,
BMI INTEGER,
Smoker INTEGER,
Stroke INTEGER,
HeartDiseaseorAttack INTEGER,
PhysActivity INTEGER,
Fruits INTEGER,
Veggies INTEGER,
HvyAlcoholConsump INTEGER,
AnyHealthcare INTEGER,
NoDocbcCost INTEGER,
GenHlth INTEGER,
MentHlth INTEGER,
PhysHlth INTEGER,
DiffWalk INTEGER,
Sex INTEGER,
Age INTEGER,
Education INTEGER,
Income INTEGER
);
