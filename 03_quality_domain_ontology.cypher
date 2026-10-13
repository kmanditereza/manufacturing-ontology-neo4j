// ============================================================
// 03 — QUALITY DOMAIN
// ============================================================
// A domain extension covering the quality-control side of the
// ketchup plant. It subclasses the core concepts with the concrete
// concepts of laboratory testing, in-line inspection, and material
// disposition, and specialises a few core relationships.
//
// PATTERN
//   Concept       -> (:Class:Quality {uri, name, description})
//                    wired to a core concept by (child)-[:SUBCLASS_OF]->(parent)
//   Relationship  -> (:Relationship:Quality {uri, name, description})
//                    wired to the core relationship it refines by
//                    (child)-[:SPECIALIZES]->(parent), and to its own
//                    (narrower) HAS_DOMAIN / HAS_RANGE concepts.
//
// Domain / range remain descriptive, not database-enforced.
// Load order: after 01_core_ontology. Idempotent (MERGE on uri).
// ============================================================


// ============================================================
// 1. Locations  (SUBCLASS_OF WorkCenter)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualityLaboratory'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualityLaboratory',
    c.description = 'The controlled area where samples are analysed for attributes such as pH, Brix, viscosity, colour, and microbiology.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/InspectionStation'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'InspectionStation',
    c.description = 'A point on or beside the line where product is checked against quality criteria before it is allowed to proceed.',
    c.version = '1.0.0';

MATCH (wc:Class {name: 'WorkCenter'})
MATCH (c:Class) WHERE c.name IN ['QualityLaboratory', 'InspectionStation']
MERGE (c)-[:SUBCLASS_OF]->(wc);


// ============================================================
// 2. Physical entities  (SUBCLASS_OF PhysicalEntity)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Sample'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Sample',
    c.description = 'A representative portion of material drawn from a batch or container for quality analysis.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/RetainedSample'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'RetainedSample',
    c.description = 'A sample kept in storage through the product shelf life to support later reference or investigation.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/TestEquipment'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'TestEquipment',
    c.description = 'A laboratory instrument used to measure product attributes, such as a pH meter, refractometer, or viscometer.',
    c.version = '1.0.0';

// A sample is a portion of material drawn off for test, so it is Material.
MATCH (core:Class {name: 'Material'})
MATCH (c:Class) WHERE c.name IN ['Sample', 'RetainedSample']
MERGE (c)-[:SUBCLASS_OF]->(core);

// Laboratory instruments are Equipment.
MATCH (core:Class {name: 'Equipment'})
MATCH (c:Class) WHERE c.name IN ['TestEquipment']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 3. Processes  (SUBCLASS_OF Process, via QualityProcess)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualityProcess'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualityProcess',
    c.description = 'A step of work that assesses or assures product quality. Abstract parent of the inspection, sampling, testing, and disposition steps.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Inspection'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Inspection',
    c.description = 'Examining product against defined criteria to judge whether it conforms.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Sampling'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Sampling',
    c.description = 'Drawing a representative portion of material from a batch or container for analysis.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Testing'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Testing',
    c.description = 'Measuring product attributes in the laboratory against a test method.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Disposition'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Disposition',
    c.description = 'Deciding the fate of a batch or lot, such as release, rework, or reject.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/NonConformanceReview'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'NonConformanceReview',
    c.description = 'Investigating a non-conforming result to determine cause and corrective action.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'QualityProcess'}), (core:Class {name: 'Process'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'QualityProcess'})
MATCH (c:Class) WHERE c.name IN [
  'Inspection', 'Sampling', 'Testing', 'Disposition', 'NonConformanceReview' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 4. Operational entities  (SUBCLASS_OF OperationalEntity)
// Intent (define quality) and evidence (record quality).
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualitySpecification'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualitySpecification',
    c.description = 'The set of attributes and acceptance limits a product must meet, such as target pH, Brix, and viscosity ranges.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/InspectionResult'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'InspectionResult',
    c.description = 'The recorded outcome of an inspection or test, capturing measured values and a pass or fail verdict.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/CertificateOfAnalysis'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'CertificateOfAnalysis',
    c.description = 'The document certifying that a batch meets its specification, issued with released product.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Deviation'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'Deviation',
    c.description = 'A recorded departure from an approved procedure, parameter, or specification during production.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/NonConformanceReport'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'NonConformanceReport',
    c.description = 'The record documenting a non-conforming material or result and the review that follows.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualityPlan'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualityPlan',
    c.description = 'The plan defining which checks and tests apply to a product and at what stage and frequency.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/TestMethod'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'TestMethod',
    c.description = 'The documented procedure describing how a specific attribute is measured.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN [
  'QualitySpecification', 'InspectionResult', 'CertificateOfAnalysis', 'Deviation',
  'NonConformanceReport', 'QualityPlan', 'TestMethod' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 5. Agents  (SUBCLASS_OF Agent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QCTechnician'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QCTechnician',
    c.description = 'A person who performs in-line inspections and pulls samples on the floor.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualityManager'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualityManager',
    c.description = 'A person who owns the quality decision, authorizing release, hold, or rejection of batches.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/LabAnalyst'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'LabAnalyst',
    c.description = 'A person who runs laboratory tests on samples and records the results.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Agent'})
MATCH (c:Class) WHERE c.name IN ['QCTechnician', 'QualityManager', 'LabAnalyst']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 6\. Capabilities  (none — see below)
// ============================================================
// Deliberately empty. The core Capability concept is kept — separating what a
// resource CAN DO from what it is currently doing is a real distinction, and
// it is what makes resource selection and scheduling answerable. What is not
// kept is a pre-enumerated capability per process.
//
// Eight of the original domain capabilities were exact name mirrors of a
// process class (FillingCapability/Filling, RepairCapability/Repair, and so
// on), so they carried no information the process did not already carry, and
// neither HAS_CAPABILITY nor REQUIRES_CAPABILITY was ever asserted against any
// of them. Domain capabilities are added here when something actually needs to
// ask "which asset can do this?" — not in advance.

// ============================================================
// 7. Events  (SUBCLASS_OF Event, via QualityEvent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/QualityEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QualityEvent',
    c.description = 'A quality-significant occurrence in the plant. Abstract parent of the inspection, deviation, sampling, and disposition events.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/InspectionCompleted'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'InspectionCompleted',
    c.description = 'An inspection finished and recorded its verdict.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/DeviationRaised'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'DeviationRaised',
    c.description = 'A departure from an approved procedure or specification was logged.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/NonConformanceRaised'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'NonConformanceRaised',
    c.description = 'A non-conforming material or result was flagged for review.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/SampleTaken'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'SampleTaken',
    c.description = 'A sample was drawn from a batch or container.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/DispositionMade'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'DispositionMade',
    c.description = 'A release, rework, or reject decision was recorded for a batch or lot.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'QualityEvent'}), (core:Class {name: 'Event'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'QualityEvent'})
MATCH (c:Class) WHERE c.name IN [
  'InspectionCompleted', 'DeviationRaised', 'NonConformanceRaised',
  'SampleTaken', 'DispositionMade' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 8. States  (SUBCLASS_OF State)
// Quality lifecycle states for material awaiting or under judgement.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/AwaitingInspection'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'AwaitingInspectionState',
    c.description = 'Material is held pending a quality check before it may proceed.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/UnderReview'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'UnderReviewState',
    c.description = 'Material is being assessed following a non-conforming result.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Approved'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'ApprovedState',
    c.description = 'Material has passed quality judgement and is cleared for use or dispatch.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Rejected'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'RejectedState',
    c.description = 'Material has failed quality judgement and is barred from use.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/quality/Quarantined'})
ON CREATE SET c.created_at = datetime()
SET c:Quality, c.name = 'QuarantinedState',
    c.description = 'Material is isolated and blocked from movement pending a disposition decision.',
    c.version = '1.0.0';

// Quality states are dispositions of material: may this lot be used?
MATCH (core:Class {name: 'MaterialState'})
MATCH (c:Class) WHERE c.name IN [
  'AwaitingInspectionState', 'UnderReviewState', 'ApprovedState', 'RejectedState', 'QuarantinedState' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

// One-time cleanup: previously direct children of State. Idempotent.
MATCH (c:Class:Quality)-[r:SUBCLASS_OF]->(:Class {name: 'State'})
DELETE r;


// ============================================================
// 9. Specialised relationships  (SPECIALIZES a core relationship)
// Each also carries its own, narrower HAS_DOMAIN / HAS_RANGE.
// ============================================================

// --- specialisation of AFFECTS (Process/Event -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/quality/rel/INSPECTS'})
ON CREATE SET r.created_at = datetime()
SET r:Quality, r.name = 'INSPECTS',
    r.description = 'A process examines a physical entity to judge conformance. Specialises AFFECTS.',
    r.version = '1.0.0';

// --- specialisation of IS_GUIDED_BY (Process -> OperationalEntity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/quality/rel/CONFORMS_TO'})
ON CREATE SET r.created_at = datetime()
SET r:Quality, r.name = 'CONFORMS_TO',
    r.description = 'A process is governed by a specification it must meet. Specialises IS_GUIDED_BY.',
    r.version = '1.0.0';

// SPECIALIZES wiring (child relationship -> parent relationship)
MATCH (parent:Relationship {name: 'AFFECTS'})
MATCH (r:Relationship) WHERE r.name IN ['INSPECTS']
MERGE (r)-[:SPECIALIZES]->(parent);

MATCH (parent:Relationship {name: 'IS_GUIDED_BY'})
MATCH (r:Relationship) WHERE r.name IN ['CONFORMS_TO']
MERGE (r)-[:SPECIALIZES]->(parent);

// Domain wiring (the "from" side)
MATCH (r:Relationship) WHERE r.name IN ['INSPECTS', 'CONFORMS_TO']
MATCH (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// Range wiring (the "to" side)
MATCH (r:Relationship) WHERE r.name IN ['INSPECTS']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name IN ['CONFORMS_TO']
MATCH (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
