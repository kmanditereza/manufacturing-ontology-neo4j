// ============================================================
// 04 — MAINTENANCE DOMAIN
// ============================================================
// A domain extension covering the upkeep of the ketchup plant.
// It subclasses the core concepts with the concrete concepts of a
// maintenance operation — the assets kept serviceable, the work that
// keeps them so, and the health states they move through — and
// specialises a few core relationships.


// ============================================================
// 1. Locations  (SUBCLASS_OF WorkCenter)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceWorkshop'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceWorkshop',
    c.description = 'The equipped area where technicians overhaul, repair, and calibrate plant assets away from the production floor.',
    c.version = '1.0.0';

MATCH (wc:Class {name: 'WorkCenter'})
MATCH (c:Class) WHERE c.name IN ['MaintenanceWorkshop']
MERGE (c)-[:SUBCLASS_OF]->(wc);


// ============================================================
// 2. Physical entities  (SUBCLASS_OF PhysicalEntity)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/SparePart'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'SparePart',
    c.description = 'A replacement component held for maintenance, such as a filler seal, pump bearing, or homogenizer valve.',
    c.version = '1.0.0';

// A spare part is stock consumed to service an asset — it is held, issued and
// fitted rather than operated — so it is Material, not Equipment.
MATCH (core:Class {name: 'Material'})
MATCH (c:Class) WHERE c.name IN ['SparePart']
MERGE (c)-[:SUBCLASS_OF]->(core);


MATCH (c:Class) WHERE c.uri IN [
  'http://industry40.tv/ontology/maintenance/MaintenanceTool',
  'http://industry40.tv/ontology/maintenance/ConditionSensor' ]
DETACH DELETE c;


// ============================================================
// 3. Processes  (SUBCLASS_OF Process, via MaintenanceProcess)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceProcess'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceProcess',
    c.description = 'A step of work that keeps or returns plant equipment to a serviceable condition. Abstract parent of the maintenance process steps.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/CorrectiveMaintenance'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'CorrectiveMaintenance',
    c.description = 'Work carried out after a fault to restore equipment that has failed or degraded.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/PreventiveMaintenance'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'PreventiveMaintenance',
    c.description = 'Scheduled work performed at set intervals to keep equipment healthy before a fault occurs.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/PredictiveMaintenance'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'PredictiveMaintenance',
    c.description = 'Work triggered by condition data that forecasts an impending failure so intervention happens just in time.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/Repair'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'Repair',
    c.description = 'The act of fixing or replacing a faulty component to return equipment to working order.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/ConditionMonitoring'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'ConditionMonitoring',
    c.description = 'Ongoing observation of equipment health indicators to detect degradation as it emerges.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'MaintenanceProcess'}), (core:Class {name: 'Process'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'MaintenanceProcess'})
MATCH (c:Class) WHERE c.name IN [
  'CorrectiveMaintenance', 'PreventiveMaintenance', 'PredictiveMaintenance',
  'Repair', 'ConditionMonitoring' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 4. Operational entities  (SUBCLASS_OF OperationalEntity)
// Intent (plan and authorise work) and evidence (record work).
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceWorkOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceWorkOrder',
    c.description = 'The instruction that authorises and dispatches a maintenance job on a specific asset.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenancePlan'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenancePlan',
    c.description = 'The time-phased schedule of preventive tasks defined for a set of plant equipment.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/FailureReport'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'FailureReport',
    c.description = 'The record documenting a failure event, its cause, and the corrective action taken.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceProcedure'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceProcedure',
    c.description = 'The step-by-step method describing how to perform a maintenance task safely and correctly.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/SparePartsList'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'SparePartsList',
    c.description = 'The bill of spare components required to complete a given maintenance task.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN [
  'MaintenanceWorkOrder', 'MaintenancePlan', 'FailureReport',
  'MaintenanceProcedure', 'SparePartsList' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 5. Agents  (SUBCLASS_OF Agent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceTechnician'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceTechnician',
    c.description = 'A person who inspects, repairs, and services plant equipment.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/ReliabilityEngineer'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'ReliabilityEngineer',
    c.description = 'A person who analyses failure patterns and defines maintenance strategy to improve asset reliability.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Agent'})
MATCH (c:Class) WHERE c.name IN ['MaintenanceTechnician', 'ReliabilityEngineer']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 7. Events  (SUBCLASS_OF Event, via MaintenanceEvent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceEvent',
    c.description = 'An operationally significant occurrence in maintenance. Abstract parent of the fault and work-order events.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/EquipmentFailed'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'EquipmentFailed',
    c.description = 'A piece of equipment stopped performing its function.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/FaultDetected'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'FaultDetected',
    c.description = 'A fault or abnormal condition was detected on equipment.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceStarted'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceStarted',
    c.description = 'Execution of a maintenance job began.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceCompleted'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceCompleted',
    c.description = 'A maintenance job finished its work.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceWorkOrderRaised'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceWorkOrderRaised',
    c.description = 'A maintenance work order was created and authorised.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/MaintenanceWorkOrderClosed'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'MaintenanceWorkOrderClosed',
    c.description = 'A maintenance work order was completed and closed out.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'MaintenanceEvent'}), (core:Class {name: 'Event'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'MaintenanceEvent'})
MATCH (c:Class) WHERE c.name IN [
  'EquipmentFailed', 'FaultDetected', 'MaintenanceStarted', 'MaintenanceCompleted',
  'MaintenanceWorkOrderRaised', 'MaintenanceWorkOrderClosed' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 8. States  (SUBCLASS_OF State)
// Equipment health states across the maintenance lifecycle.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/HealthyState'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'HealthyState',
    c.description = 'Equipment is operating within its normal condition limits with no detected fault.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/DegradedState'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'DegradedState',
    c.description = 'Equipment still runs but its condition has worsened and points toward an emerging fault.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/FailedState'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'FailedState',
    c.description = 'Equipment has stopped performing its function and needs corrective work.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/maintenance/UnderMaintenanceState'})
ON CREATE SET c.created_at = datetime()
SET c:Maintenance, c.name = 'UnderMaintenanceState',
    c.description = 'Equipment is out of service while a maintenance job is being performed on it.',
    c.version = '1.0.0';

// Maintenance states describe the health of a physical asset, so they scope
// under EquipmentState alongside the availability values.
MATCH (core:Class {name: 'EquipmentState'})
MATCH (c:Class) WHERE c.name IN ['HealthyState', 'DegradedState', 'FailedState', 'UnderMaintenanceState']
MERGE (c)-[:SUBCLASS_OF]->(core);

// One-time cleanup: previously direct children of State. Idempotent.
MATCH (c:Class:Maintenance)-[r:SUBCLASS_OF]->(:Class {name: 'State'})
DELETE r;


// ============================================================
// 9. Specialised relationships  (SPECIALIZES a core relationship)
// Each also carries its own, narrower HAS_DOMAIN / HAS_RANGE.
// ============================================================

// --- specialisations of AFFECTS (Process/Event -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/maintenance/rel/MAINTAINS'})
ON CREATE SET r.created_at = datetime()
SET r:Maintenance, r.name = 'MAINTAINS',
    r.description = 'A process keeps or returns equipment to a serviceable condition. Specialises AFFECTS.',
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/maintenance/rel/RESTORES'})
ON CREATE SET r.created_at = datetime()
SET r:Maintenance, r.name = 'RESTORES',
    r.description = 'A process returns failed equipment to working order. Specialises AFFECTS.',
    r.version = '1.0.0';

// SPECIALIZES wiring (child relationship -> parent relationship)
MATCH (parent:Relationship {name: 'AFFECTS'})
MATCH (r:Relationship) WHERE r.name IN ['MAINTAINS', 'RESTORES']
MERGE (r)-[:SPECIALIZES]->(parent);

// Domain wiring (the "from" side)
MATCH (r:Relationship) WHERE r.name IN ['MAINTAINS', 'RESTORES']
MATCH (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// Range wiring (the "to" side)
MATCH (r:Relationship) WHERE r.name IN ['MAINTAINS', 'RESTORES']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
