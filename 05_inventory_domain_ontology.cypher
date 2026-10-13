// ============================================================
// 05 — INVENTORY DOMAIN
// ============================================================
// A domain extension for materials and warehousing. It subclasses
// the core concepts with the concrete concepts of a ketchup plant's
// inventory operations — the places materials are held, the loads
// and lots they are held as, the movements that relocate them, and
// the records that account for them — and specialises a few core
// relationships.
//
// PATTERN
//   Concept       -> (:Class:Inventory {uri, name, description})
//                    wired to a core concept by (child)-[:SUBCLASS_OF]->(parent)
//   Relationship  -> (:Relationship:Inventory {uri, name, description})
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

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Warehouse'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Warehouse',
    c.description = 'The building that holds raw materials, packaging components, and finished ketchup pending dispatch.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StorageZone'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StorageZone',
    c.description = 'A demarcated area within a warehouse grouping storage locations by condition or purpose (e.g. ambient, chilled, hazardous).',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/ReceivingArea'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'ReceivingArea',
    c.description = 'The dock area where inbound deliveries of ingredients and packaging are unloaded and checked before putaway.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/DispatchArea'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'DispatchArea',
    c.description = 'The dock area where finished-goods pallets are staged and loaded onto outbound vehicles.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/QuarantineStore'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'QuarantineStore',
    c.description = 'A segregated location holding material that is on hold pending quality release or disposition.',
    c.version = '1.0.0';

MATCH (area:Class {name: 'Area'})
MATCH (c:Class) WHERE c.name IN ['Warehouse', 'ReceivingArea', 'DispatchArea']
MERGE (c)-[:SUBCLASS_OF]->(area);

MATCH (wc:Class {name: 'WorkCenter'})
MATCH (c:Class) WHERE c.name IN ['StorageZone', 'QuarantineStore']
MERGE (c)-[:SUBCLASS_OF]->(wc);


// ============================================================
// 2. Physical entities  (SUBCLASS_OF PhysicalEntity)
// The lots and holders that inventory is tracked and held as.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialLot'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialLot',
    c.description = 'A traceable quantity of a single material received or produced together and sharing one lot code.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StorageBin'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StorageBin',
    c.description = 'A discrete addressable position on a rack or shelf that holds a unit load or quantity of material.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Silo'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Silo',
    c.description = 'A bulk vessel storing dry ingredients such as sugar or starch ahead of the batch process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StorageTank'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StorageTank',
    c.description = 'A bulk vessel storing liquid ingredients such as vinegar or oil ahead of the batch process.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Hopper'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Hopper',
    c.description = 'A small feed vessel that meters a minor dry ingredient — spice, salt or additive — into the batch on demand. Distinguished from a Silo by duty rather than shape: a silo holds bulk, a hopper doses.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/UnitLoad'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'UnitLoad',
    c.description = 'A palletized grouping of material — typically shipping cases stacked on a pallet — handled, stored and dispatched as a single unit. A grouping of material rather than a kind of material, so it is not a Material.',
    c.version = '1.0.0';

// MaterialLot and UnitLoad sit directly under PhysicalEntity, as siblings of
// both Equipment and Material. Neither is a KIND of material: a lot is a
// tracked QUANTITY of one and a unit load is a GROUPING of one. Subclassing
// either under Material would mix the definition tier with the quantity tier,
// so a lot reaches its material through IS_QUANTITY_OF (section 9) instead.
MATCH (core:Class {name: 'PhysicalEntity'})
MATCH (c:Class) WHERE c.name IN ['MaterialLot', 'UnitLoad']
MERGE (c)-[:SUBCLASS_OF]->(core);

// The vessels and positions that hold inventory are Equipment.
MATCH (core:Class {name: 'Equipment'})
MATCH (c:Class) WHERE c.name IN ['StorageBin', 'Silo', 'StorageTank', 'Hopper']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 3. Processes  (SUBCLASS_OF Process, via InventoryProcess)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/InventoryProcess'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'InventoryProcess',
    c.description = 'A step of work that receives, stores, moves, or accounts for material. Abstract parent of the warehousing process steps.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialReceipt'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialReceipt',
    c.description = 'Taking delivery of inbound material and booking it into stock.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Putaway'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Putaway',
    c.description = 'Moving received material from the receiving area to its assigned storage location.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Picking'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Picking',
    c.description = 'Retrieving material from storage to satisfy a production or dispatch demand.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialTransfer'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialTransfer',
    c.description = 'Relocating material from one storage location to another within the site.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StockCount'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StockCount',
    c.description = 'Physically counting material on hand to verify it against recorded quantities.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/Dispatch'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'Dispatch',
    c.description = 'Loading finished-goods pallets onto an outbound vehicle and removing them from stock.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'InventoryProcess'}), (core:Class {name: 'Process'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'InventoryProcess'})
MATCH (c:Class) WHERE c.name IN [
  'MaterialReceipt', 'Putaway', 'Picking', 'MaterialTransfer', 'StockCount', 'Dispatch' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 4. Operational entities  (SUBCLASS_OF OperationalEntity)
// Intent (direct work) and evidence (record work).
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/InventoryRecord'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'InventoryRecord',
    c.description = 'The accounting record of the on-hand quantity of a material at a location.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialTransferOrder'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialTransferOrder',
    c.description = 'The instruction authorizing a movement of material between locations.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StockCountRecord'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StockCountRecord',
    c.description = 'The as-counted record of a stock count, capturing counted quantity and variance against book stock.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/GoodsReceipt'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'GoodsReceipt',
    c.description = 'The record confirming inbound material was received against a purchase order.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/PickList'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'PickList',
    c.description = 'The instruction listing the materials and quantities to retrieve for a demand.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN [
  'InventoryRecord', 'MaterialTransferOrder', 'StockCountRecord', 'GoodsReceipt', 'PickList' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 5. Agents  (SUBCLASS_OF Agent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/WarehouseOperator'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'WarehouseOperator',
    c.description = 'A person who receives, stores, and issues material and maintains stock accuracy.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialHandler'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialHandler',
    c.description = 'A person or vehicle that physically moves unit loads between locations.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Agent'})
MATCH (c:Class) WHERE c.name IN ['WarehouseOperator', 'MaterialHandler']
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
// 7. Events  (SUBCLASS_OF Event, via InventoryEvent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/InventoryEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'InventoryEvent',
    c.description = 'An operationally significant occurrence in inventory. Abstract parent of the material movement and count events.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialReceived'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialReceived',
    c.description = 'A quantity of material was received into stock.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialIssued'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialIssued',
    c.description = 'A quantity of material was issued out of stock to a demand.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialTransferred'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialTransferred',
    c.description = 'A quantity of material was moved from one location to another.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/StockCounted'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'StockCounted',
    c.description = 'A material was physically counted and its variance recorded.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/MaterialQuarantined'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'MaterialQuarantined',
    c.description = 'A material was placed on hold and moved to quarantine pending disposition.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'InventoryEvent'}), (core:Class {name: 'Event'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'InventoryEvent'})
MATCH (c:Class) WHERE c.name IN [
  'MaterialReceived', 'MaterialIssued', 'MaterialTransferred', 'StockCounted', 'MaterialQuarantined' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 8. States  (SUBCLASS_OF State)
// Inventory availability lifecycle states.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/AvailableState'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'AvailableState',
    c.description = 'Stock is on hand and free to be consumed or shipped.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/ReservedState'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'ReservedState',
    c.description = 'Stock is earmarked for a specific demand but not yet allocated to it.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/AllocatedState'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'AllocatedState',
    c.description = 'Stock is committed to a demand and no longer available to others.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/InTransitState'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'InTransitState',
    c.description = 'Stock is being moved between locations and is not yet at its destination.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/inventory/DepletedState'})
ON CREATE SET c.created_at = datetime()
SET c:Inventory, c.name = 'DepletedState',
    c.description = 'Stock of a material at a location has been fully consumed.',
    c.version = '1.0.0';

// Inventory states describe the availability of material as stock.
MATCH (core:Class {name: 'MaterialState'})
MATCH (c:Class) WHERE c.name IN ['AvailableState', 'ReservedState', 'AllocatedState', 'InTransitState', 'DepletedState']
MERGE (c)-[:SUBCLASS_OF]->(core);

// One-time cleanup: previously direct children of State. Idempotent.
MATCH (c:Class:Inventory)-[r:SUBCLASS_OF]->(:Class {name: 'State'})
DELETE r;


// ============================================================
// 9. Specialised relationships  (SPECIALIZES a core relationship)
// Each also carries its own, narrower HAS_DOMAIN / HAS_RANGE.
// ============================================================

// --- specialisation of AFFECTS (Process/Event -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/inventory/rel/MOVES'})
ON CREATE SET r.created_at = datetime()
SET r:Inventory, r.name = 'MOVES',
    r.description = 'A process relocates a material from one place to another. Specialises AFFECTS.',
    r.version = '1.0.0';

// --- specialisation of IS_LOCATED_AT (PhysicalEntity -> Location) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/inventory/rel/STORED_AT'})
ON CREATE SET r.created_at = datetime()
SET r:Inventory, r.name = 'STORED_AT',
    r.description = 'A material lot is held at a storage location. Specialises IS_LOCATED_AT.',
    r.version = '1.0.0';

// --- the definition/quantity bridge (MaterialLot -> Material) ---
// Deliberately SPECIALIZES nothing: no core relationship expresses the
// definition/quantity split, so this is a new relation rather than a
// narrowing of an existing one. It is what keeps MaterialLot off the
// Material subclass tree while still tying a lot to what it is a lot OF.
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/inventory/rel/IS_QUANTITY_OF'})
ON CREATE SET r.created_at = datetime()
SET r:Inventory, r.name = 'IS_QUANTITY_OF',
    r.description = 'A tracked quantity of stuff is a quantity of a given kind of material. Separates the definition tier (Material — what kind of stuff this is) from the quantity tier (MaterialLot — which specific lot, under one lot code, with its own receipt, status and genealogy). The ISA-95 Material Definition / Material Lot split.',
    r.examples = ['LOT-TP-2026-0438 IS_QUANTITY_OF RawMaterial', 'LOT-KTC-2026-MUC-04471 IS_QUANTITY_OF FinishedProduct'],
    r.version = '1.0.0';

// SPECIALIZES wiring (child relationship -> parent relationship)
MATCH (parent:Relationship {name: 'AFFECTS'})
MATCH (r:Relationship) WHERE r.name IN ['MOVES']
MERGE (r)-[:SPECIALIZES]->(parent);

MATCH (parent:Relationship {name: 'IS_LOCATED_AT'})
MATCH (r:Relationship) WHERE r.name IN ['STORED_AT']
MERGE (r)-[:SPECIALIZES]->(parent);

// Domain wiring (the "from" side)
MATCH (r:Relationship) WHERE r.name IN ['MOVES']
MATCH (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship) WHERE r.name IN ['STORED_AT']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_DOMAIN]->(c);

MATCH (r:Relationship) WHERE r.name IN ['IS_QUANTITY_OF']
MATCH (c:Class {name: 'MaterialLot'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// Range wiring (the "to" side)
MATCH (r:Relationship) WHERE r.name IN ['MOVES']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name IN ['STORED_AT']
MATCH (c:Class {name: 'Location'})
MERGE (r)-[:HAS_RANGE]->(c);

MATCH (r:Relationship) WHERE r.name IN ['IS_QUANTITY_OF']
MATCH (c:Class {name: 'Material'})
MERGE (r)-[:HAS_RANGE]->(c);
