create  database fineupp;
create schema websson;

CREATE OR REPLACE WAREHOUSE websson_wh WITH WAREHOUSE_SIZE='X-SMALL';

create role websson;

grant role websson to user xxx;


CREATE COMPUTE POOL websson_compute_pool
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS;

show compute pools;

--alter compute pool DOCKER_COMPUTE_POOL suspend;
--alter compute pool DOCKER_COMPUTE_POOL resume;

CREATE IMAGE REPOSITORY IF NOT EXISTS images;

ls @images;

SHOW IMAGE REPOSITORIES IN SCHEMA;


CREATE STAGE IF NOT EXISTS container_volumes
ENCRYPTION = (TYPE='SNOWFLAKE_SSE');


ls @container_volumes;


GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE websson;

CREATE NETWORK RULE websson_rule
  TYPE = 'HOST_PORT'
  MODE= 'EGRESS'
  VALUE_LIST = ('0.0.0.0:443');

-- optionally 
-- alter network rule allow_ssh_rule set VALUE_LIST = ('0.0.0.0:443','xxxxxx.hetz-fsn-prod-x.fineupp.com');
  
CREATE EXTERNAL ACCESS INTEGRATION allow_websson
  ALLOWED_NETWORK_RULES=(websson_rule)
  ENABLED=TRUE;

GRANT USAGE ON INTEGRATION allow_websson TO ROLE websson;

DESCRIBE COMPUTE POOL websson_compute_pool;


grant usage on compute pool websson_compute_pool to role websson;
grant operate on compute pool websson_compute_pool to role websson;
grant monitor on compute pool websson_compute_pool to role websson;
grant modify on compute pool websson_compute_pool to role websson;
grant usage on warehouse websson_wh to role websson;
grant all privileges on database fineupp to role websson;
grant all privileges on schema websson to role websson;

use role websson;

DESCRIBE COMPUTE POOL websson_compute_pool;


 CREATE SERVICE websson_python_service
  IN COMPUTE POOL websson_compute_pool
  MIN_INSTANCES=1
  MAX_INSTANCES=1
  EXTERNAL_ACCESS_INTEGRATIONS = (allow_ssh_eai)
  FROM SPECIFICATION
  $$
   spec:
    containers:
    - name: "pythonplatform"
      image: "/xxx/xxx/images/websson-python-image:latest"
      env:
        SPCS: "True"
        SERVICEURL: "https://xxx.hetz-fsn-prod-x.fineupp.com/extraport/startme_from_env.sh"
        SECRETSURL: "https://xxx.hetz-fsn-prod-x.fineupp.com/extraport/secrets"
        SSHKEY: "False"
        SUPERVISOR: "False"
        VSVERSION: "1.93.0"
        USERPASS: "admin"
        ENVNAME: "testing"
        JUPTOKEN: "juptoken"
        VSTOKEN: "testing"

    endpoints:
      - name: http
        port: 5000
        public: true
      - name: vscode
        port: 3000
        public: true

  $$;


  
describe service websson_python_service;
drop service websson_python_service;

--alter service websson_python_service suspend;
--alter service websson_python_servicee resume;

SHOW SERVICE CONTAINERS IN SERVICE websson_python_service;
SHOW IMAGES IN IMAGE REPOSITORY images;


CALL SYSTEM$GET_SERVICE_LOGS('websson_python_service', '0', 'pythonplatform', 1000);
GRANT SERVICE ROLE websson_python_service!ALL_ENDPOINTS_USAGE TO ROLE websson;


SHOW ENDPOINTS IN SERVICE websson_python_service;

