// ============================================================
// 02 — PRODUCTION DOMAIN
// ============================================================
// The first domain extension. It subclasses the nine core concepts
// directly (flat, 2-tier) with the concrete concepts of a ketchup
// production floor — the make side (batch process) and the pack side
// (discrete flow) — and specialises a few core relationships.
//
// PATTERN
//   Concept       -> (:Class:Production {uri, name, description})
//                    wired to a core concept by (child)-[:SUBCLASS_OF]->(parent)
//   Relationship  -> (:Relationship:Production {uri, name, description})
//                    wired to the core relationship it refines by
//                    (child)-[:SPECIALIZES]->(parent), and to its own
//                    (narrower) HAS_DOMAIN / HAS_RANGE concepts.
//
// Domain / range remain descriptive, not database-enforced.
// Load order: after 01_core_ontology. Idempotent (MERGE on uri).
// ============================================================


// ============================================================
// 1. Locations  (SUBCLASS_OF Area / WorkCenter)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionArea'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionArea',
    c.description = 'The functional area where raw materials are transformed into bulk product through batch processing (pre-mix, cook, deaerate, homogenize, buffer).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PackagingArea'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PackagingArea',
    c.description = 'The functional area where bulk product is packaged into finished goods through discrete-flow operations (fill, cap, label, code, inspect, case-pack, palletize).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionLine'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionLine',
    c.description = 'A production-area work centre: the batch process cell grouping the make-side units that execute recipe phases to produce a defined batch.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PackagingLine'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PackagingLine',
    c.description = 'A packaging-area work centre: the sequenced arrangement of stations through which bulk product flows to become pallet-ready finished goods.',
    c.version = '1.0.0';

MATCH (area:Class {name: 'Area'})
MATCH (c:Class) WHERE c.name IN ['ProductionArea', 'PackagingArea']
MERGE (c)-[:SUBCLASS_OF]->(area);

MATCH (wc:Class {name: 'WorkCenter'})
MATCH (c:Class) WHERE c.name IN ['ProductionLine', 'PackagingLine']
MERGE (c)-[:SUBCLASS_OF]->(wc);


// ============================================================
// 2. Equipment
// ============================================================
// Production defines no equipment classes. The make-side units and pack-side
// stations (Mixer, Kettle, Filler, Case Packer, ...) are instances of the core
// class Equipment, and their kinds are entries in the equipment class catalogue
// -- Plant IT master data, mirrored into the graph -- that each asset points to
// with IS_OF_CLASS.

// One-time cleanup: these kinds of equipment were classes before the equipment
// class catalogue (Plant IT master data, mirrored into the graph). Assets no
// longer reference them -- they are instances of Equipment, classified with
// IS_OF_CLASS -- so drop the old class nodes. Idempotent. Retire once every
// deployed graph has run it.
MATCH (c:Class) WHERE c.uri IN [
  'http://industry40.tv/ontology/production/PreMixer',
  'http://industry40.tv/ontology/production/CookKettle',
  'http://industry40.tv/ontology/production/Deaerator',
  'http://industry40.tv/ontology/production/Homogenizer',
  'http://industry40.tv/ontology/production/BufferTank',
  'http://industry40.tv/ontology/production/Filler',
  'http://industry40.tv/ontology/production/Capper',
  'http://industry40.tv/ontology/production/Labeler',
  'http://industry40.tv/ontology/production/DateCoder',
  'http://industry40.tv/ontology/production/XRayInspector',
  'http://industry40.tv/ontology/production/CasePacker',
  'http://industry40.tv/ontology/production/Palletizer',
  'http://industry40.tv/ontology/production/InversionTunnel',
  'http://industry40.tv/ontology/production/CoolingTunnel',
  'http://industry40.tv/ontology/production/Conveyor' ]
DETACH DELETE c;


// ============================================================
// 3. Materials  (SUBCLASS_OF core Material)
// ============================================================
// The inputs, in-process product and packaging attach directly to the core
// Material class. There is no intermediate ProductionMaterial parent: the
// :Production label and the /production/ URI namespace already carry which
// domain owns a material.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/RawMaterial'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'RawMaterial',
    c.description = 'An input ingredient consumed by the batch process (e.g. tomato paste, sugar, vinegar, spice blend).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/IntermediateProduct'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'IntermediateProduct',
    c.description = 'In-process bulk product between stages (e.g. cooked, deaerated, or buffered ketchup) not yet packaged.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/FinishedProduct'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'FinishedProduct',
    c.description = 'Packaged, released product ready for distribution.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PrimaryContainer'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PrimaryContainer',
    c.description = 'The bottle or jar that directly holds the product.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Closure'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Closure',
    c.description = 'The cap or lid that seals the primary container.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Label'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Label',
    c.description = 'The applied label carrying product and regulatory information.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ShippingCase'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ShippingCase',
    c.description = 'A corrugated case grouping finished containers for handling.',
    c.version = '1.0.0';

// Pallet is deliberately absent. It described "a unit load of cases for
// warehousing and dispatch" — a grouping of material rather than a material —
// which is the inventory domain's UnitLoad. The two were the same concept
// declared in two domains; UnitLoad is the one that survives.

// The inputs, in-process product and packaging are Material.
MATCH (core:Class {name: 'Material'})
MATCH (c:Class) WHERE c.name IN [
  'RawMaterial', 'IntermediateProduct', 'FinishedProduct',
  'PrimaryContainer', 'Closure', 'Label', 'ShippingCase' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 4. Processes  (SUBCLASS_OF Process, via ProductionProcess)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionProcess'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionProcess',
    c.description = 'A step of work that makes or packages product. Abstract parent of the make and pack process steps.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PreMixing'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PreMixing',
    c.description = 'Combining and hydrating ingredients into a uniform pre-blend.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Cooking'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Cooking',
    c.description = 'Heating and holding the blend to pasteurize and activate thickeners.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Deaeration'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Deaeration',
    c.description = 'Removing entrained air from the product under vacuum.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Homogenization'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Homogenization',
    c.description = 'Shearing the product to a stable, uniform emulsion.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Buffering'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Buffering',
    c.description = 'Holding bulk product hot between production and filling.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Filling'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Filling',
    c.description = 'Dosing product into primary containers.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Capping'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Capping',
    c.description = 'Applying and sealing closures.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Labeling'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Labeling',
    c.description = 'Applying labels to containers.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Coding'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Coding',
    c.description = 'Printing lot and date codes onto containers.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ForeignBodyInspection'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ForeignBodyInspection',
    c.description = 'Screening product for contaminants (e.g. X-ray, metal detection).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Cooling'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Cooling',
    c.description = 'Reducing hot-filled product temperature to ambient.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/CasePacking'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'CasePacking',
    c.description = 'Grouping containers into cases.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Palletizing'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Palletizing',
    c.description = 'Stacking cases onto pallets.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/CleaningInPlace'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'CleaningInPlace',
    c.description = 'Cleaning equipment internals between runs without disassembly.',
    c.version = '1.0.0';

// ----- The ISA-88 procedural tiers of a batch -----
// Every BatchPhase event on the wire carries three nested identifiers —
// batchRecordId, operationNumber/operationName, phaseNumber/phaseName — so the
// make side has three procedural levels, not one. They are modelled as three
// process classes, nested at the INSTANCE level with the core HAS_SUBPROCESS
// relationship (Process -> Process):
//
//   Batch          B-20260603-001
//     HAS_SUBPROCESS  BatchOperation  'Cook'                (operation 0020)
//       HAS_SUBPROCESS  BatchPhase    'PasteurizationHold'  (phase 0023)
//
// A phase is PART OF a batch, not a KIND OF batch, so the nesting is
// HAS_SUBPROCESS and never SUBCLASS_OF. All three are siblings under
// ProductionProcess.
//
// Phase names (DoseWater, HeatToTarget, PullVacuum, …) are deliberately NOT
// classes. They are recipe-specific and unbounded — a new SKU brings new
// phases — so they stay instance data on the phase, carried in `phaseName`.
// The named operations below are stable process types for this plant and do
// remain classes.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Batch'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Batch',
    c.description = 'One execution of a control recipe that produces a defined quantity of product under a single batch identity. The unit of genealogy: material consumed, phases run, deviations raised and quality disposition all attach to it.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchOperation'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchOperation',
    c.description = 'A named stage within a batch that groups the phases achieving one processing objective, such as pre-mixing, cooking, or deaerating and homogenizing. Parent of the concrete make-side operations.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchPhase'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchPhase',
    c.description = 'The smallest procedural step of a batch — a single dose, hold, transfer or vacuum step run on one unit under a named phase logic. The finest grain at which the plant reports start, completion, hold and abort.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'ProductionProcess'}), (core:Class {name: 'Process'})
MERGE (p)-[:SUBCLASS_OF]->(core);

// Batch, its operations and its phases, plus the pack-side steps, are all
// production processes. The pack side is discrete flow rather than batch
// structured, so its steps stay directly under ProductionProcess.
MATCH (p:Class {name: 'ProductionProcess'})
MATCH (c:Class) WHERE c.name IN [
  'Batch', 'BatchOperation', 'BatchPhase',
  'Filling', 'Capping', 'Labeling', 'Coding', 'ForeignBodyInspection',
  'Cooling', 'CasePacking', 'Palletizing', 'CleaningInPlace' ]
MERGE (c)-[:SUBCLASS_OF]->(p);

// The make-side steps are the batch operations the wire names in
// `operationName`: PreMix, Cook, DeaerateAndHomogenize.
MATCH (p:Class {name: 'BatchOperation'})
MATCH (c:Class) WHERE c.name IN [
  'PreMixing', 'Cooking', 'Deaeration', 'Homogenization', 'Buffering' ]
MERGE (c)-[:SUBCLASS_OF]->(p);

// One-time cleanup: the make-side steps previously subclassed ProductionProcess
// directly and now reach it through BatchOperation. Drop the redundant direct
// edge so each keeps a single parent. Idempotent: a no-op once it is gone.
// Retire this block once every deployed graph has run it.
MATCH (c:Class)-[r:SUBCLASS_OF]->(:Class {name: 'ProductionProcess'})
WHERE c.name IN ['PreMixing', 'Cooking', 'Deaeration', 'Homogenization', 'Buffering']
DELETE r;


// ============================================================
// 5. Operational entities  (SUBCLASS_OF OperationalEntity)
// Intent (define work) and evidence (record work).
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/MasterRecipe'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'MasterRecipe',
    c.description = 'The product- and site-independent recipe defining how to make a product; the template control recipes are generated from.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ControlRecipe'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ControlRecipe',
    c.description = 'The batch-specific recipe instance downloaded to equipment, carrying the procedure, parameters, and material bindings for one batch.',
    c.version = '1.0.0';

// Planning-side and execution-side orders each get a parent. Make and pack are
// kept as distinct subclasses (a process order runs a recipe and yields batches;
// a packaging order consumes those batches and yields discrete units against a
// SKU), but they share a lifecycle and a dispatch relationship, and those are
// declared once on the parent rather than twice on the children.
MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionOrder',
    c.description = 'A planning-side order authorising production: the ERP view of work to be done. Umbrella for process orders (make) and packaging orders (pack), which share its lifecycle. Not the SAP discrete-manufacturing order type of the same name.',
    c.examples = ['ProcessOrder', 'PackagingOrder'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionWorkOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionWorkOrder',
    c.description = 'An execution-side work order dispatched to a line: the MES view of a production order being carried out. Umbrella for make-side and pack-side work orders, which share its lifecycle.',
    c.examples = ['WorkOrder', 'PackagingWorkOrder'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProcessOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProcessOrder',
    c.description = 'The ERP/MES order authorizing production of a quantity of a material.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/WorkOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'WorkOrder',
    c.description = 'The dispatch instruction that releases a process order to a line as executable work.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PackagingOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PackagingOrder',
    c.description = 'The order authorizing packaging of bulk product into a finished SKU.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PackagingWorkOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PackagingWorkOrder',
    c.description = 'The execution-side work order dispatched to a packaging line, carrying out a PackagingOrder. The pack-side sibling of WorkOrder under ProductionWorkOrder, kept distinct so make and pack lifecycles stay separately traceable.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionSchedule'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionSchedule',
    c.description = 'The time-phased plan sequencing orders across lines.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchRecord'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchRecord',
    c.description = 'The as-executed record of a batch: procedure, parameters, materials, deviations, and results.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionResponse'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionResponse',
    c.description = 'The reported outcome of executing an order: produced quantity, consumption, and performance.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN [
  'MasterRecipe', 'ControlRecipe', 'ProductionOrder', 'ProductionWorkOrder',
  'ProductionSchedule', 'BatchRecord', 'ProductionResponse' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'ProductionOrder'})
MATCH (c:Class) WHERE c.name IN ['ProcessOrder', 'PackagingOrder']
MERGE (c)-[:SUBCLASS_OF]->(p);

MATCH (p:Class {name: 'ProductionWorkOrder'})
MATCH (c:Class) WHERE c.name IN ['WorkOrder', 'PackagingWorkOrder']
MERGE (c)-[:SUBCLASS_OF]->(p);

// One-time cleanup: the four orders previously hung directly off
// OperationalEntity and now sit under ProductionOrder / ProductionWorkOrder.
// Drop the redundant direct edge so each keeps a single parent. Idempotent.
// Retire once every deployed graph has run it.
MATCH (c:Class)-[r:SUBCLASS_OF]->(:Class {name: 'OperationalEntity'})
WHERE c.name IN ['ProcessOrder', 'PackagingOrder', 'WorkOrder', 'PackagingWorkOrder']
DELETE r;


// ============================================================
// 6. Agents  (SUBCLASS_OF Agent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/Operator'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Operator',
    c.description = 'A person who runs and tends production equipment.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ShiftSupervisor'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ShiftSupervisor',
    c.description = 'A person who coordinates and authorizes work across a shift.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/LineController'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'LineController',
    c.description = 'The automation controller that drives the equipment of a line and reports its operational state.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchManagementSystem'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchManagementSystem',
    c.description = 'The software that sequences batch procedures and records their execution.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Agent'})
MATCH (c:Class) WHERE c.name IN ['Operator', 'ShiftSupervisor', 'LineController', 'BatchManagementSystem']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 7\. Capabilities  (none — see below)
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

// One-time cleanup: retire the domain capability classes. They were name
// mirrors of process classes with no instance ever asserted against them.
// Idempotent. Retire this block once every deployed graph has run it.
MATCH (c:Class)-[:SUBCLASS_OF]->(:Class {name: 'Capability'})
WHERE c.name <> 'Capability'
DETACH DELETE c;

// ============================================================
// 8. Roles  (SUBCLASS_OF Role)
// The common participation roles. Cross-domain; defined here as the
// first domain to use them, reused by later domains.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/InputRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Input',
    c.description = 'The role of a material consumed by a process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/OutputRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Output',
    c.description = 'The role of a physical entity produced by a process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PerformerRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Performer',
    c.description = 'The role of the entity that carries out a process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ConsumerRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Consumer',
    c.description = 'The role of an entity that uses up a resource.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProducerRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Producer',
    c.description = 'The role of an entity that creates an output.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ControllerRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Controller',
    c.description = 'The role of an agent that directs or governs a process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ObserverRole'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'Observer',
    c.description = 'The role of an entity that monitors a process without altering it.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Role'})
MATCH (c:Class) WHERE c.name IN ['Input', 'Output', 'Performer', 'Consumer', 'Producer', 'Controller', 'Observer']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 9. Events  (SUBCLASS_OF Event, via ProductionEvent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionEvent',
    c.description = 'An operationally significant occurrence in production. Abstract parent of the batch and material events.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchScheduled'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchScheduled',
    c.description = 'A batch was placed on the schedule for a line.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchStarted'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchStarted',
    c.description = 'Execution of a batch began.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchCompleted'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchCompleted',
    c.description = 'A batch finished its procedure.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BatchReleased'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BatchReleased',
    c.description = 'A completed batch was released by QA for downstream use.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PhaseStarted'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PhaseStarted',
    c.description = 'A batch phase began.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PhaseCompleted'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PhaseCompleted',
    c.description = 'A batch phase finished.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/MaterialConsumed'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'MaterialConsumed',
    c.description = 'A quantity of material was consumed by a process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/MaterialProduced'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'MaterialProduced',
    c.description = 'A quantity of product was produced by a process.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'ProductionEvent'}), (core:Class {name: 'Event'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'ProductionEvent'})
MATCH (c:Class) WHERE c.name IN [
  'BatchScheduled', 'BatchStarted', 'BatchCompleted', 'BatchReleased',
  'PhaseStarted', 'PhaseCompleted', 'MaterialConsumed', 'MaterialProduced' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 10. States  (SUBCLASS_OF State)
// Equipment operational states and order/batch lifecycle states.
// ============================================================

// The two order lifecycles. Scoped here, not in core, because their subjects —
// ProductionOrder and ProductionWorkOrder — are production concepts. They are
// separate lifecycles of the same work: an order can be Released in ERP while
// its work order is still only Received by MES, and one order can be split
// across several work orders.
MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionOrderState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionOrderState',
    c.description = 'The condition of a production order as the planning system sees it, from creation through release to technical completion and closure. The ERP view of authorised work.',
    c.examples = ['Planned', 'Released', 'Completed', 'Closed'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ProductionWorkOrderState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ProductionWorkOrderState',
    c.description = 'The condition of a production work order as the execution system sees it, from receipt through dispatch and activation to completion and closure. The MES view, deliberately distinct from the planning view a ProductionOrderState carries.',
    c.examples = ['Received', 'Dispatched', 'Active', 'Completed'],
    c.version = '1.0.0';

MATCH (s:Class {name: 'State'})
MATCH (c:Class) WHERE c.name IN ['ProductionOrderState', 'ProductionWorkOrderState']
MERGE (c)-[:SUBCLASS_OF]->(s);

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/RunningState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'RunningState',
    c.description = 'Equipment is executing its process and producing.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/IdleState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'IdleState',
    c.description = 'Equipment is available but not producing.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/StarvedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'StarvedState',
    c.description = 'Equipment is stopped for lack of upstream input.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/BlockedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'BlockedState',
    c.description = 'Equipment is stopped because downstream cannot accept output.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PlannedDowntimeState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PlannedDowntimeState',
    c.description = 'Equipment is down for a scheduled reason (e.g. changeover, cleaning).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/UnplannedDowntimeState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'UnplannedDowntimeState',
    c.description = 'Equipment is down for an unscheduled reason (e.g. fault).',
    c.version = '1.0.0';

// Distinct from the downtime states: those describe an asset that is expected
// to be producing and is not. Disabled means the asset is not expected to run
// at all, so it should be excluded from availability rather than counted as
// lost time.
MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/DisabledState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'DisabledState',
    c.description = 'Equipment is out of service and not scheduled to run — powered down, decommissioned, or taken off the line. Not counted against availability.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ChangeoverState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ChangeoverState',
    c.description = 'Equipment is being switched from one product or format to another.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ScheduledState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ScheduledState',
    c.description = 'An order or batch is planned but not yet started.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/InProductionState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'StartedState',
    c.description = 'An order or batch is currently executing.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/CompletedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'CompletedState',
    c.description = 'An order or batch has finished execution.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/OnHoldState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'HeldState',
    c.description = 'An order or batch is paused pending a decision.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ReleasedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'MaterialReleasedState',
    c.description = 'A batch has been QA-released for downstream use.',
    c.version = '1.0.0';


// ----- Order lifecycle (ERP view) -----
// SAP status codes CRTD / REL / TECO / CLSD, as carried in `status_system`.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/PlannedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'PlannedState',
    c.description = 'An order exists in planning but is not yet authorised for execution (SAP CRTD).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/OrderReleasedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'OrderReleasedState',
    c.description = 'An order has been authorised by planning and may be executed (SAP REL). Distinct from MaterialReleasedState, which is a lab disposition of produced material.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/OrderCompletedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'OrderCompletedState',
    c.description = 'An order is technically complete: the work it authorised has been executed (SAP TECO).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/OrderClosedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'OrderClosedState',
    c.description = 'An order is settled and closed to further postings (SAP CLSD).',
    c.version = '1.0.0';


// ----- Work order lifecycle (MES view) -----

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ReceivedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ReceivedState',
    c.description = 'A work order has arrived at execution but has not yet been dispatched to a line.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/DispatchedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'DispatchedState',
    c.description = 'A work order has been sent to a specific work centre and awaits activation.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ActiveState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ActiveState',
    c.description = 'A work order is live on the floor: its batches or runs may start against it.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/WorkOrderCompletedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'WorkOrderCompletedState',
    c.description = 'A work order has finished execution on the floor.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/WorkOrderClosedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'WorkOrderClosedState',
    c.description = 'A work order is closed in execution and reported back to planning.',
    c.version = '1.0.0';


// ----- Operator interventions on a running execution -----

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/ResumedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'ResumedState',
    c.description = 'A held execution has been returned to running by an operator.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/StoppedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'StoppedState',
    c.description = 'An execution has been halted by an operator and may not resume from where it left off.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/AbortedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'AbortedState',
    c.description = 'An execution was terminated before completion; any product made is not fit for normal disposition.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/CancelledState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'CancelledState',
    c.description = 'A scheduled execution was withdrawn before it started.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/production/DisposedState'})
ON CREATE SET c.created_at = datetime()
SET c:Production, c.name = 'DisposedState',
    c.description = 'Material has been scrapped or otherwise removed from stock without being used.',
    c.version = '1.0.0';

// The availability values describe a physical asset.
MATCH (core:Class {name: 'EquipmentState'})
MATCH (c:Class) WHERE c.name IN [
  'RunningState', 'IdleState', 'StarvedState', 'BlockedState',
  'PlannedDowntimeState', 'UnplannedDowntimeState', 'ChangeoverState',
  'DisabledState' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

// Batch, operation, phase and packaging-run executions.
MATCH (core:Class {name: 'ProcessState'})
MATCH (c:Class) WHERE c.name IN [
  'ScheduledState', 'StartedState', 'CompletedState', 'HeldState',
  'ResumedState', 'StoppedState', 'AbortedState', 'CancelledState' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

// Order lifecycle as planning sees it.
MATCH (core:Class {name: 'ProductionOrderState'})
MATCH (c:Class) WHERE c.name IN [
  'PlannedState', 'OrderReleasedState', 'OrderCompletedState', 'OrderClosedState' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

// Work order lifecycle as execution sees it.
MATCH (core:Class {name: 'ProductionWorkOrderState'})
MATCH (c:Class) WHERE c.name IN [
  'ReceivedState', 'DispatchedState', 'ActiveState',
  'WorkOrderCompletedState', 'WorkOrderClosedState' ]
MERGE (c)-[:SUBCLASS_OF]->(core);

// A batch is released by the lab, not by planning — this is a quality
// disposition of the produced material, not an order status.
MATCH (core:Class {name: 'MaterialState'})
MATCH (c:Class) WHERE c.name IN ['MaterialReleasedState', 'DisposedState']
MERGE (c)-[:SUBCLASS_OF]->(core);

// One-time cleanup: the production states previously hung directly off State
// and are now scoped. Drop the redundant direct edge so each keeps a single
// parent. Idempotent. Retire once every deployed graph has run it.
// The two order scopes are excluded: they are production classes whose parent
// really is State.
MATCH (c:Class:Production)-[r:SUBCLASS_OF]->(:Class {name: 'State'})
WHERE NOT c.name IN ['ProductionOrderState', 'ProductionWorkOrderState']
DELETE r;

// One-time cleanup: the order scopes moved here from core under new names. The
// leaf states are now wired to ProductionOrderState / ProductionWorkOrderState,
// so drop the old core classes and their edges. Idempotent. Retire once every
// deployed graph has run it.
MATCH (c:Class) WHERE c.uri IN [
  'http://industry40.tv/ontology/core/OrderState',
  'http://industry40.tv/ontology/core/WorkOrderState' ]
DETACH DELETE c;


// ============================================================
// 11. Specialised relationships  (SPECIALIZES a core relationship)
// Each also carries its own, narrower HAS_DOMAIN / HAS_RANGE.
// ============================================================

// --- specialisations of AFFECTS (Process/Event -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/CONSUMES'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'CONSUMES',
    r.description = 'A process uses up a material as input. Specialises AFFECTS.',
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/YIELDS'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'YIELDS',
    r.description = 'A process creates a physical output (intermediate or finished product). Specialises AFFECTS. Distinct from the core PRODUCES, which creates informational evidence.',
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/TRANSFORMS'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'TRANSFORMS',
    r.description = 'A process changes the form or properties of a material. Specialises AFFECTS.',
    r.version = '1.0.0';

// --- specialisations of IS_GUIDED_BY (Process -> OperationalEntity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/EXECUTES'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'EXECUTES',
    r.description = 'A process carries out a recipe. Specialises IS_GUIDED_BY.',
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/FULFILLS'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'FULFILLS',
    r.description = 'A process satisfies an order. Specialises IS_GUIDED_BY.',
    r.version = '1.0.0';

// --- the order cascade (OperationalEntity -> OperationalEntity) ---
// Deliberately SPECIALIZES nothing: every core relationship that touches an
// OperationalEntity has a Process or Event on the other side, so none of them
// expresses one informational object becoming another. Planning issues a
// process order; execution receives it as a work order; the two are distinct
// objects owned by distinct systems, and the link between them is the join
// that makes an order traceable from ERP through to the floor.
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/production/rel/IS_DISPATCHED_AS'})
ON CREATE SET r.created_at = datetime()
SET r:Production, r.name = 'IS_DISPATCHED_AS',
    r.description = 'A planning-side order is released to execution as a work order. Connects the ERP view of authorised work to the MES view that carries it out, so a batch can be traced back to the order that authorised it.',
    r.examples = ['ProcessOrder IS_DISPATCHED_AS WorkOrder', 'PackagingOrder IS_DISPATCHED_AS PackagingWorkOrder'],
    r.version = '1.0.0';

// SPECIALIZES wiring (child relationship -> parent relationship)
MATCH (parent:Relationship {name: 'AFFECTS'})
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES', 'YIELDS', 'TRANSFORMS']
MERGE (r)-[:SPECIALIZES]->(parent);

MATCH (parent:Relationship {name: 'IS_GUIDED_BY'})
MATCH (r:Relationship) WHERE r.name IN ['EXECUTES', 'FULFILLS']
MERGE (r)-[:SPECIALIZES]->(parent);

// Domain wiring (the "from" side)
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES', 'YIELDS', 'TRANSFORMS', 'EXECUTES', 'FULFILLS']
MATCH (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship) WHERE r.name IN ['IS_DISPATCHED_AS']
MATCH (c:Class {name: 'ProductionOrder'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// Range wiring (the "to" side)
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES', 'YIELDS', 'TRANSFORMS']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name IN ['EXECUTES', 'FULFILLS']
MATCH (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name IN ['IS_DISPATCHED_AS']
MATCH (c:Class {name: 'ProductionWorkOrder'})
MERGE (r)-[:HAS_RANGE]->(c);

// One-time cleanup: IS_DISPATCHED_AS previously ran OperationalEntity ->
// OperationalEntity. Drop those edges now that it is narrowed to
// ProductionOrder -> ProductionWorkOrder. Idempotent. Retire once every
// deployed graph has run it.
MATCH (r:Relationship {name: 'IS_DISPATCHED_AS'})-[e:HAS_DOMAIN|HAS_RANGE]->(:Class {name: 'OperationalEntity'})
DELETE e;
