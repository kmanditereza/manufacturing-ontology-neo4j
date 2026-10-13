// ============================================================
// 01 — CORE MANUFACTURING ONTOLOGY
// ============================================================
// The small, precise core: nine concepts and the relationships
// that connect them. Deliberately abstract — it does NOT define
// machine types, failure modes, material properties, inspection
// methods, or regulatory rules. Those belong in domain extensions,
// which subclass these concepts and specialise these relationships.
//
// MODEL
//   Concept       -> (:Class:Core {uri, name, description, examples})
//   Relationship  -> (:Relationship:Core {uri, name, description, examples})
//                    a REIFIED node so it can carry a definition and be
//                    specialised later. It is wired to its concept(s) by:
//                      (:Relationship)-[:HAS_DOMAIN]->(:Class)   the "from" side
//                      (:Relationship)-[:HAS_RANGE ]->(:Class)   the "to" side
//
// Domain / range are DESCRIPTIVE, not database-enforced: Neo4j cannot
// constrain the endpoints of an arbitrary edge, so they guide instance
// creation and agent reasoning; the ingestion layer enforces them.
//
// Nodes are upserted with MERGE on `uri` (the stable identity).
// `created_at` is stamped only on first creation; the rest is kept in
// sync on every run.
//
// Load order: after 00_constraints. Idempotent.
// ============================================================


// ============================================================
// 1. Concepts
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Process'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Process',
    c.description = 'Work that happens over time and creates, transforms, moves, inspects, maintains, or otherwise affects something. A process may contain subprocesses and may be executed manually, automatically, or through a combination of people, equipment and software.',
    c.examples = ['Mixing', 'Welding', 'Packaging', 'Inspection', 'Cleaning', 'Material transfer'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/PhysicalEntity'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'PhysicalEntity',
    c.description = 'A physical entity that exists within the manufacturing environment. Describes what something IS, not the role it plays in a particular process.',
    c.examples = ['Material', 'Product', 'Equipment', 'Tool', 'Container', 'Sample'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/OperationalEntity'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'OperationalEntity',
    c.description = 'An informational object that directs, constrains, describes, or records operational work. Divides broadly into entities that describe intended work and entities that provide evidence of completed work.',
    c.examples = ['Order', 'Schedule', 'Recipe', 'Procedure', 'Specification', 'Work instruction', 'Production record', 'Inspection result'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Agent'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Agent',
    c.description = 'Something capable of participating in, controlling, or making decisions about a process. It may supervise, coordinate, control, approve, or decide rather than perform the physical transformation itself.',
    c.examples = ['Personnel', 'Team', 'Equipment controller', 'Software application', 'AI agent'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Location'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Location',
    c.description = 'Where an entity, agent, or process exists or occurs. The ISA-95 equipment hierarchy extends this concept.',
    c.examples = ['Enterprise', 'Site', 'Area', 'Work center', 'Work unit'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Capability'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Capability',
    c.description = 'What an entity, agent, or organizational unit is able to do. Separates what a resource CAN DO from the process it is currently executing; may carry constraints or parameters.',
    c.examples = ['Mixing capability', 'Filling capability', 'Temperature-measurement capability', 'Sterilization capability', 'Inspection capability'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Role'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Role',
    c.description = 'How an entity participates in a particular process or relationship. The same entity may play different roles in different contexts, so a role is interpreted within a context rather than as a permanent classification.',
    c.examples = ['Input', 'Output', 'Performer', 'Observer', 'Controller', 'Consumer', 'Producer'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Event'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Event',
    c.description = 'Something operationally significant that occurred at a particular point or interval in time. Provides the time-based operational evidence needed for analytics, traceability, and agentic decision-making.',
    c.examples = ['Process started', 'Order released', 'Material consumed', 'Alarm activated', 'Inspection completed', 'Equipment failed'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/State'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'State',
    c.description = 'The condition of an entity or process during a period of time. Events usually cause or indicate state changes.',
    c.examples = ['Running', 'Idle', 'Failed', 'Available', 'In production', 'Awaiting inspection', 'Released', 'Quarantined'],
    c.version = '1.0.0';


// ============================================================
// 2. Concept hierarchy
// ============================================================
// There is deliberately no abstract "Entity" supertype over PhysicalEntity,
// Agent and OperationalEntity. Relationships that apply to more than one of
// them name each one explicitly instead — see sections 4 and 5, where multiple
// HAS_DOMAIN / HAS_RANGE edges are read as an allowed union. That is the same
// mechanism AFFECTS already uses across Process and Event, so the supertype
// bought nothing the model could not already express, while widening several
// domains past what they should permit (an OperationalEntity has no
// capability and is not located anywhere).


// ============================================================
// 2b. Structural location hierarchy (ISA-95)
// ============================================================
// The ISA-95 spatial spine — Enterprise, Site, Area, Work Center — as
// subclasses of Location, the shared vocabulary every domain locates work
// against. These are role-based location LEVELS; the instance-level
// containment between them (a Site is part of an Enterprise) is asserted with
// CONTAINS, not by subclassing, so here they are four siblings under Location.
// Domain extensions specialise Area and Work Center (ProductionArea,
// PackagingLine, StorageZone, …).
//
// Work Unit is deliberately omitted: a physical asset fills the work-unit role,
// so equipment (a PhysicalEntity) attaches directly to its Work Center via
// IS_LOCATED_AT rather than to a redundant 1:1 location level.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Enterprise'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Enterprise',
    c.description = 'The organization or business entity that owns and operates one or more sites. The top of the ISA-95 spatial hierarchy.',
    c.examples = ['Global Industries'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Site'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Site',
    c.description = 'A physical location where operations are conducted, such as a manufacturing plant. Belongs to an Enterprise and is divided into Areas.',
    c.examples = ['Munich Plant', 'Dallas Plant'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Area'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Area',
    c.description = 'A functional division of a site that groups the work centres serving a common purpose. Domain extensions specialise it (ProductionArea, PackagingArea, UtilitiesArea, Warehouse).',
    c.examples = ['Production Area', 'Packaging Area', 'Utilities Area', 'Raw Material Storage Area'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/WorkCenter'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'WorkCenter',
    c.description = 'A location within an area where work is performed — a production line, packaging line, storage zone, or utility system. The finest shared spatial grain; equipment is located at a work centre. Domain extensions specialise it (ProductionLine, PackagingLine, StorageZone).',
    c.examples = ['Production Line 1', 'Packaging Line 1', 'Dry Ingredient Storage', 'Steam System'],
    c.version = '1.0.0';

MATCH (loc:Class {name: 'Location'})
MATCH (c:Class) WHERE c.name IN ['Enterprise', 'Site', 'Area', 'WorkCenter']
MERGE (c)-[:SUBCLASS_OF]->(loc);


// ============================================================
// 2c. Physical entity tier (equipment and material)
// ============================================================
// The counterpart of the location spine on the PhysicalEntity branch. Every
// physical thing in the plant divides on one question: does the plant OPERATE
// it, or does it FLOW THROUGH? Equipment is operated; Material is consumed,
// transformed or dispatched. Domain extensions specialise Material into kinds
// (RawMaterial, Closure, Sample), as they specialise Area and WorkCenter.
// Equipment is NOT specialised: kinds of equipment are catalogue entries
// (section 2f), so every asset is an instance of Equipment itself.
//
// Two kinds of physical entity sit alongside these rather than below them,
// deliberately:
//   - EnergyCarrier (energy domain) — Electricity is not a substance, so the
//     carriers are not modelled as Material.
//   - MaterialLot and UnitLoad (inventory domain) — a lot is a tracked
//     QUANTITY of a material and a unit load is a GROUPING of material, not a
//     kind of material. Subclassing either under Material would mix the
//     definition tier with the quantity tier. MaterialLot reaches Material
//     through IS_QUANTITY_OF instead.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Equipment'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Equipment',
    c.description = 'A physical asset the plant installs, operates and maintains in order to carry out work — it transforms, moves, packages, measures, stores or services something, rather than being consumed by the process itself. Located at a Work Center, and the entity that equipment states, modes and maintenance are asserted against. Not subclassed: an asset is an instance of Equipment, and its kind is the equipment class catalogue entry it points to with IS_OF_CLASS.',
    c.examples = ['Filler', 'Cook Kettle', 'Boiler', 'Energy Meter', 'pH Meter', 'Condition Sensor', 'Storage Tank', 'Torque Wrench'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/Material'})
ON CREATE SET c.created_at = datetime()
SET c:Core,
    c.name = 'Material',
    c.description = 'A kind of physical stuff that flows through the plant — consumed as input, carried through the process, packaged into the product, drawn off for test, or held to service an asset. Material is a DEFINITION, not a quantity: it answers what kind of stuff this is, while a tracked quantity of it is a MaterialLot related by IS_QUANTITY_OF. Domain extensions specialise it into concrete material types.',
    c.examples = ['Raw Material', 'Intermediate Product', 'Finished Product', 'Primary Container', 'Closure', 'Label', 'Shipping Case', 'Sample', 'Spare Part'],
    c.version = '1.0.0';

MATCH (pe:Class {name: 'PhysicalEntity'})
MATCH (c:Class) WHERE c.name IN ['Equipment', 'Material']
MERGE (c)-[:SUBCLASS_OF]->(pe);


// ============================================================
// 2d. State scopes
// ============================================================
// State on its own is too coarse: a flat vocabulary lets a work order be
// 'Running' and a filler be 'Completed'. A scope says WHOSE lifecycle a state
// belongs to, so every domain classifies conditions the same way.
//
// Core defines the three scopes whose subjects are core concepts: equipment,
// process and material. A lifecycle that belongs to a domain concept is scoped
// in that domain — the order lifecycles (ProductionOrderState,
// ProductionWorkOrderState) live in production, beside the orders they describe,
// because core has no notion of an order to hang them on.
//
// NAMING: every state class ends in `State` — RunningState, HeldState,
// OrderClosedState. Classes share one namespace, and the natural name for a
// state is also the natural name for the event that causes it (BatchCompleted
// the event vs BatchCompleted the state). The suffix keeps the two apart and
// makes the kind of a class readable without traversing to its parent.
//
// Where the same word means different things in different scopes it is
// qualified as well: an order is released by ERP (authorised to run) while a
// material is released by the lab (approved for dispatch) — OrderReleasedState
// and MaterialReleasedState are not the same condition.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/EquipmentState'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'EquipmentState',
    c.description = 'The condition of a physical asset — whether it is producing, waiting, stopped, or unavailable, and its health. Scopes the availability vocabulary used for OEE and maintenance.',
    c.examples = ['Running', 'Starved', 'Blocked', 'Planned downtime', 'Degraded'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/ProcessState'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'ProcessState',
    c.description = 'The condition of a process execution — a batch, an operation, a phase, or a packaging run — as it moves from scheduled through running to finished, including operator interventions that hold or abandon it.',
    c.examples = ['Started', 'Completed', 'Held', 'Aborted'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/MaterialState'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'MaterialState',
    c.description = 'The condition of material — its quality disposition and its availability as stock. Covers both whether the material may be used and whether it is on hand and unreserved.',
    c.examples = ['Quarantined', 'Approved', 'Available', 'Depleted'],
    c.version = '1.0.0';

MATCH (s:Class {name: 'State'})
MATCH (c:Class) WHERE c.name IN
  ['EquipmentState', 'ProcessState', 'MaterialState']
MERGE (c)-[:SUBCLASS_OF]->(s);


// ============================================================
// 2e. Equipment state change events
// ============================================================
// The event that carries an equipment state transition. It lives in core
// because no business process raises it: the machine reports its own change
// (Running -> Starved), dozens of times an hour, in the same shape for every
// asset. With no process behind it, no domain owns it. A filler's change
// matters to production and a compressor's to energy, but the event is the
// same, and putting it in either domain would force the other to import it.
//
// Process and material changes are different. They are caused by a business
// activity that belongs to one domain: production starts a batch, the lab
// releases a lot, the warehouse receives stock. Those are recorded by that
// domain's own events (BatchStarted, MaterialQuarantined, ...) through
// CHANGES_STATE / TRANSITIONS_TO, so they need no core counterpart. Which is
// why there is no ProcessStateChangeEvent or MaterialStateChangeEvent here.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/EquipmentStateChangeEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'EquipmentStateChangeEvent',
    c.description = 'A record that a physical asset moved from one equipment state to another at a point in time. Carries the transition itself, so the ordered chain of these events reconstructs the availability history of an asset without depending on the current HAS_STATE edge.',
    c.examples = ['Filler FL501 Running -> Starved', 'Compressor AC801 Idle -> Running'],
    c.version = '1.0.0';

MATCH (e:Class {name: 'Event'})
MATCH (c:Class {name: 'EquipmentStateChangeEvent'})
MERGE (c)-[:SUBCLASS_OF]->(e);


// ============================================================
// 2f. Equipment class catalogue
// ============================================================
// Kinds of equipment (Filler, Case Packer, Boiler, Tank, ...) are NOT ontology
// classes. An asset is an instance of the single class Equipment, and its kind
// is a catalogue entry it points to with IS_OF_CLASS -- the ISA-95 Equipment
// Class. Adding a new kind of machine is then a row of master data, not a
// change to the ontology.
//
// The catalogue is mastered in Plant IT (equipment_class,
// equipment_class_property) and mirrored into the graph as instances of the two
// classes below. A catalogue entry is informational -- it describes a kind of
// equipment and what its members are expected to provide -- so both sit under
// OperationalEntity, not PhysicalEntity.
//
// The two relationships keep meaning and classification apart:
//   SUBCLASS_OF / IS_INSTANCE_OF  what a thing IS, in the ontology's terms
//   IS_OF_CLASS                   which catalogue entry classifies it
//
// See Design_Note_Equipment_Class_Catalogue.md.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/EquipmentClass'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'EquipmentClass',
    c.description = 'A catalogue entry describing a kind of equipment and what every member of that kind is expected to provide. Mastered as data; an asset is classified against one with IS_OF_CLASS. The ISA-95 Equipment Class.',
    c.examples = ['Filler', 'Case Packer', 'Boiler', 'Tank', 'Power Monitoring Unit'],
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/core/PropertyDefinition'})
ON CREATE SET c.created_at = datetime()
SET c:Core, c.name = 'PropertyDefinition',
    c.description = 'A property that members of an equipment class are expected to provide -- its name, unit, data type and whether it is required. The definition of a property, not a value of it: values arrive on the UNS.',
    c.examples = ['Filler speed (BPM, required)', 'Tank level (%, required)', 'Case Packer hydraulic pressure (bar, optional)'],
    c.version = '1.0.0';

MATCH (oe:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN ['EquipmentClass', 'PropertyDefinition']
MERGE (c)-[:SUBCLASS_OF]->(oe);


// ============================================================
// 3. Relationships (reified)
// ============================================================

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/AFFECTS'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'AFFECTS',
    r.description = 'A process or event changes, handles, moves, inspects, maintains, or otherwise influences an entity. The broadest process/event-to-entity relationship; domain extensions introduce specialisations such as TRANSFORMS, MOVES, INSPECTS, CONSUMES and PRODUCES.',
    r.examples = ['Mixing AFFECTS Material', 'Maintenance AFFECTS Equipment', 'EquipmentFailureEvent AFFECTS Order'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/PARTICIPATES_IN'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'PARTICIPATES_IN',
    r.description = 'An entity is involved in the execution of a process. Participation alone does not explain HOW the entity is involved — that is expressed through a Role.',
    r.examples = ['Mixer PARTICIPATES_IN MixingExecution', 'Operator PARTICIPATES_IN MixingExecution', 'MaterialLot PARTICIPATES_IN MixingExecution'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/PLAYS_ROLE'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'PLAYS_ROLE',
    r.description = 'How an entity participates in a particular process, event, or operational context. Interpreted within that context; an entity need not play the same role permanently.',
    r.examples = ['MaterialLot PLAYS_ROLE Input', 'Mixer PLAYS_ROLE Performer', 'Operator PLAYS_ROLE Supervisor'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/HAS_CAPABILITY'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'HAS_CAPABILITY',
    r.description = 'An entity is able to do something, independent of the work it is currently performing. A mixer has a mixing capability even when idle; a person may be qualified for an inspection without currently inspecting.',
    r.examples = ['Mixer HAS_CAPABILITY MixingCapability', 'Operator HAS_CAPABILITY ReactorOperationCapability'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/REQUIRES_CAPABILITY'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'REQUIRES_CAPABILITY',
    r.description = 'A capability that must be available for a process to be executed. Separates the definition of the required work from the specific resource selected to perform it.',
    r.examples = ['MixingProcess REQUIRES_CAPABILITY MixingCapability', 'SterilizationProcess REQUIRES_CAPABILITY SterilizationCapability'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/IS_GUIDED_BY'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'IS_GUIDED_BY',
    r.description = 'An operational entity defines, directs, constrains, or governs how a process should be performed. Domain extensions specialise this as EXECUTES, CONFORMS_TO, FULFILLS, FOLLOWS and IS_SCHEDULED_BY.',
    r.examples = ['MixingExecution IS_GUIDED_BY Recipe', 'InspectionExecution IS_GUIDED_BY QualitySpecification', 'CleaningExecution IS_GUIDED_BY CleaningProcedure'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/PRODUCES'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'PRODUCES',
    r.description = 'An informational object created as a result of executing a process — the operational evidence of the work (records, results, decisions), as distinct from any physical entity produced.',
    r.examples = ['ProductionProcess PRODUCES ProductionRecord', 'InspectionProcess PRODUCES InspectionResult'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/OCCURS_AT'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'OCCURS_AT',
    r.description = 'The location where a process takes place or an event was raised. A process may occur at more than one location; domain extensions may add STARTS_AT and ENDS_AT for spatial detail.',
    r.examples = ['PackagingExecution OCCURS_AT PackagingLine', 'InspectionExecution OCCURS_AT QualityLaboratory', 'DowntimeStarted OCCURS_AT ProductionLine1'],
    r.version = '1.0.0';

// The work authorised by a document, or carried out by a process execution, is
// performed at a place. Distinct from IS_LOCATED_AT, which says where a physical
// thing SITS: an order is not located anywhere — it is paperwork — but the work
// it authorises happens somewhere, and that is what makes "which orders ran on
// Line 1" answerable without walking to a batch first.
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/IS_EXECUTED_AT'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'IS_EXECUTED_AT',
    r.description = 'The location where the work an operational entity authorises, or a process execution performs, is carried out. Contrast IS_LOCATED_AT, which places a physical entity, and OCCURS_AT, which places a process or an event in space.',
    r.examples = ['ProcessOrder IS_EXECUTED_AT ProductionLine1', 'PackagingOrder IS_EXECUTED_AT PackagingLine1'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/IS_LOCATED_AT'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'IS_LOCATED_AT',
    r.description = 'Where an entity currently exists or is installed. May be permanent, temporary, or time-dependent; use a temporal assertion where location history matters.',
    r.examples = ['Mixer IS_LOCATED_AT ProcessingLine', 'MaterialLot IS_LOCATED_AT StorageArea'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/OCCURS_DURING'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'OCCURS_DURING',
    r.description = 'The process execution during which an event occurred, providing the operational context needed to interpret the event (which recipe applied, which material, which equipment).',
    r.examples = ['TemperatureDeviation OCCURS_DURING MixingExecution', 'AlarmActivation OCCURS_DURING PackagingExecution'],
    r.version = '1.0.0';

// ----- The event's subject -----
// The weakest, broadest event-to-subject link, and deliberately so. An
// ingestion layer knows WHICH thing a message is about long before it can
// judge HOW the event relates to it, so CONCERNS is what it asserts. The
// stronger claims are separate and are made only where they are true:
//
//   AFFECTS       the event changed the thing
//   CHANGES_STATE the event moved it to a new state
//   OCCURS_DURING the event happened inside that process's time window
//
// The distinction is not academic. A BatchReleased event CONCERNS its batch,
// but it is a laboratory release raised after the batch finished — so it did
// NOT occur during it. Collapsing the two would assert something false.
//
// Keeping this relationship broad is what lets the mapping layer stay dumb:
// it links the event to its subject and leaves the interpretation to the
// ontology, rather than branching on the subject's type to pick an edge.

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/CONCERNS'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'CONCERNS',
    r.description = 'The process or operational entity an event is about. Asserts only that the event is a fact concerning that thing — not that it changed it, nor that it happened within its time window. The broadest event-to-subject link, and the one an ingestion layer can always assert; more precise relationships are refined from it.',
    r.examples = ['BatchPhaseStarted CONCERNS Batch', 'WorkOrderActivated CONCERNS WorkOrder', 'BatchReleased CONCERNS Batch'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/CHANGES_STATE'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'CHANGES_STATE',
    r.description = 'An event caused or indicated a change in the state of an entity or process. It names WHAT changed; the state it changed to is named by TRANSITIONS_TO on the same event.',
    r.examples = ['EquipmentFailureEvent CHANGES_STATE Mixer', 'ProcessStartEvent CHANGES_STATE MixingExecution'],
    r.version = '1.0.0';

// ----- How state is asserted -----
// An entity carries exactly one HAS_STATE edge, to its CURRENT state; the edge
// is replaced when the state changes. History is not accumulated on the entity.
// Instead each event records the state it produced, so the sequence of events
// ordered by time IS the state history:
//
//   (wo)-[:HAS_STATE]->(:ActiveState)                  current, one hop
//   (evt)-[:CHANGES_STATE]->(wo)                       what changed
//   (evt)-[:TRANSITIONS_TO]->(:ActiveState)            what it became
//   (evt)-[:TRANSITIONS_FROM]->(:DispatchedState)      optional; absent on the first
//
// The event node already carries the timestamp and provenance a separate state
// assertion would hold — eventTime, source origin, gateway and system — so it
// serves as the assertion rather than duplicating it into another node. Where a
// regulated audit trail needs more (authority, reason, electronic signature), a
// reified StateAssertion remains the right escalation; it is deliberately not
// the default. Durations and time-in-state stay in the historian with the
// rest of the time-series data.
//
// These specialise nothing: no core relationship expresses event-to-state.

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/TRANSITIONS_TO'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'TRANSITIONS_TO',
    r.description = 'The state an entity or process entered as a result of an event. Together with the event timestamp this fixes when the state began, so an ordered walk of events reconstructs the state history without storing it on the entity.',
    r.examples = ['WorkOrderActivated TRANSITIONS_TO ActiveState', 'EquipmentFailureEvent TRANSITIONS_TO FailedState'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/TRANSITIONS_FROM'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'TRANSITIONS_FROM',
    r.description = 'The state an entity or process left as a result of an event. Optional — it is derivable from the preceding event and is absent on the first event in a lifecycle — but recording it makes a transition queryable without ordering.',
    r.examples = ['WorkOrderActivated TRANSITIONS_FROM DispatchedState', 'EquipmentFailureEvent TRANSITIONS_FROM RunningState'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/HAS_STATE'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'HAS_STATE',
    r.description = 'The condition of an entity or process during a period of time. Use a state assertion (with validity period and provenance) where historical accuracy or auditability is required.',
    r.examples = ['Mixer HAS_STATE Running', 'BatchRun HAS_STATE OnHold', 'MaterialLot HAS_STATE Quarantined'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/HAS_SUBPROCESS'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'HAS_SUBPROCESS',
    r.description = 'Decomposition of a process into smaller processes, for definitions or executions. Distinct from sequencing (PRECEDES): HAS_SUBPROCESS expresses part-of, not order.',
    r.examples = ['PackagingProcess HAS_SUBPROCESS Filling', 'BatchRun HAS_SUBPROCESS MixingExecution'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/CONTAINS'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'CONTAINS',
    r.description = 'Spatial decomposition of manufacturing locations. Reserved for genuine spatial containment; organizational, responsibility, or scheduling groupings belong to separate concepts.',
    r.examples = ['Site CONTAINS Area', 'Area CONTAINS WorkCenter', 'WorkCenter CONTAINS WorkUnit'],
    r.version = '1.0.0';

// ----- Equipment classification (see 2f) -----
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/IS_OF_CLASS'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'IS_OF_CLASS',
    r.description = 'Classifies an asset against its equipment class catalogue entry -- what kind of equipment it is, in the terms the plant uses. Classification, not meaning: the asset remains an instance of Equipment.',
    r.examples = ['FL-501 IS_OF_CLASS Filler', 'BT-451 IS_OF_CLASS Tank'],
    r.version = '1.0.0';

MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/core/rel/HAS_PROPERTY_DEFINITION'})
ON CREATE SET r.created_at = datetime()
SET r:Core,
    r.name = 'HAS_PROPERTY_DEFINITION',
    r.description = 'A property every member of an equipment class is expected to provide. Defined per class; the same measurement uses the same name and unit across classes by convention.',
    r.examples = ['Filler HAS_PROPERTY_DEFINITION speed', 'Tank HAS_PROPERTY_DEFINITION level'],
    r.version = '1.0.0';


// ============================================================
// 4. Domain wiring — (:Relationship)-[:HAS_DOMAIN]->(:Class)  (the "from" side)
// ============================================================
// Relationships that accept more than one kind of source name each one; the
// multiple edges are read as an allowed union.
//
// PhysicalEntity and Agent share the relationships that describe taking part
// in work — HAS_CAPABILITY, IS_LOCATED_AT, PARTICIPATES_IN, PLAYS_ROLE. An
// OperationalEntity is deliberately NOT a domain of those four: an order has
// no capability, a recipe is not located anywhere, and neither takes part in
// work or plays a role in it. Informational objects relate to work through
// IS_GUIDED_BY and PRODUCES instead. They remain a domain of HAS_STATE and a
// range of AFFECTS / CHANGES_STATE, where they genuinely belong — an order is
// released, and an equipment failure affects it.

MATCH (r:Relationship {name: 'AFFECTS'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'AFFECTS'}), (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'PARTICIPATES_IN'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'PARTICIPATES_IN'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'PLAYS_ROLE'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'PLAYS_ROLE'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'HAS_CAPABILITY'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'HAS_CAPABILITY'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'REQUIRES_CAPABILITY'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'IS_GUIDED_BY'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'PRODUCES'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'OCCURS_AT'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// An event is raised somewhere too. Without this, an event that concerns no
// order or batch — a line downtime, a disposal — has nothing it can attach to
// and sits in the graph unreachable from the plant topology.
MATCH (r:Relationship {name: 'OCCURS_AT'}), (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'IS_EXECUTED_AT'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'IS_EXECUTED_AT'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'IS_LOCATED_AT'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'IS_LOCATED_AT'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'OCCURS_DURING'}), (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'CONCERNS'}), (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'CHANGES_STATE'}), (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship) WHERE r.name IN ['TRANSITIONS_TO', 'TRANSITIONS_FROM']
MATCH (c:Class {name: 'Event'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'HAS_STATE'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'HAS_STATE'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'HAS_STATE'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);
MATCH (r:Relationship {name: 'HAS_STATE'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'HAS_SUBPROCESS'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'CONTAINS'}), (c:Class {name: 'Location'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'IS_OF_CLASS'}), (c:Class {name: 'Equipment'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship {name: 'HAS_PROPERTY_DEFINITION'}), (c:Class {name: 'EquipmentClass'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// The one OperationalEntity that may carry HAS_CAPABILITY. An equipment class
// does not perform anything itself; it declares the capabilities every member
// provides (a Tank stores, a Power Monitoring Unit meters). This is how
// differences in behaviour are expressed without equipment subclasses.
MATCH (r:Relationship {name: 'HAS_CAPABILITY'}), (c:Class {name: 'EquipmentClass'})
MERGE (r)-[:HAS_DOMAIN]->(c);


// ============================================================
// 5. Range wiring — (:Relationship)-[:HAS_RANGE]->(:Class)  (the "to" side)
// ============================================================

MATCH (r:Relationship {name: 'AFFECTS'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
MATCH (r:Relationship {name: 'AFFECTS'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_RANGE]->(c);
MATCH (r:Relationship {name: 'AFFECTS'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'PARTICIPATES_IN'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'PLAYS_ROLE'}), (c:Class {name: 'Role'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'HAS_CAPABILITY'}), (c:Class {name: 'Capability'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'REQUIRES_CAPABILITY'}), (c:Class {name: 'Capability'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'IS_GUIDED_BY'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'PRODUCES'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'OCCURS_AT'}), (c:Class {name: 'Location'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'IS_EXECUTED_AT'}), (c:Class {name: 'Location'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'IS_LOCATED_AT'}), (c:Class {name: 'Location'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'OCCURS_DURING'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name = 'CONCERNS'
MATCH (c:Class) WHERE c.name IN ['Process', 'OperationalEntity']
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'CHANGES_STATE'}), (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
MATCH (r:Relationship) WHERE r.name IN ['TRANSITIONS_TO', 'TRANSITIONS_FROM']
MATCH (c:Class {name: 'State'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'CHANGES_STATE'}), (c:Class {name: 'Agent'})
MERGE (r)-[:HAS_RANGE]->(c);
MATCH (r:Relationship {name: 'CHANGES_STATE'}), (c:Class {name: 'OperationalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
MATCH (r:Relationship {name: 'CHANGES_STATE'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'HAS_STATE'}), (c:Class {name: 'State'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'HAS_SUBPROCESS'}), (c:Class {name: 'Process'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'CONTAINS'}), (c:Class {name: 'Location'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'IS_OF_CLASS'}), (c:Class {name: 'EquipmentClass'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship {name: 'HAS_PROPERTY_DEFINITION'}), (c:Class {name: 'PropertyDefinition'})
MERGE (r)-[:HAS_RANGE]->(c);
