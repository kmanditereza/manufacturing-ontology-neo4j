// ============================================================
// 06 — ENERGY DOMAIN
// ============================================================
// An energy / utilities extension. It subclasses the core concepts
// with the concrete concepts of a ketchup plant's energy operations —
// the utilities that supply power, steam, compressed air and cooling,
// the carriers they deliver, and the metering and demand-management
// work that governs their cost — and specialises a few core
// relationships.
//
// PATTERN
//   Concept       -> (:Class:Energy {uri, name, description})
//                    wired to a core concept by (child)-[:SUBCLASS_OF]->(parent)
//   Relationship  -> (:Relationship:Energy {uri, name, description})
//                    wired to the core relationship it refines by
//                    (child)-[:SPECIALIZES]->(parent), and to its own
//                    (narrower) HAS_DOMAIN / HAS_RANGE concepts.
//
// Domain / range remain descriptive, not database-enforced.
// Load order: after 01_core_ontology. Idempotent (MERGE on uri).
// ============================================================


// ============================================================
// 1. Locations  (UtilitiesArea SUBCLASS_OF Area; MeteringPoint SUBCLASS_OF Location)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/UtilitiesArea'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'UtilitiesArea',
    c.description = 'The functional area housing the plant utilities that generate and distribute steam, compressed air, cooling water and electrical power to production.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/MeteringPoint'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'MeteringPoint',
    c.description = 'A defined point in the plant where an energy carrier is measured, such as the incoming utility supply or a submeter on a production line.',
    c.version = '1.0.0';

MATCH (area:Class {name: 'Area'})
MATCH (c:Class) WHERE c.name IN ['UtilitiesArea']
MERGE (c)-[:SUBCLASS_OF]->(area);

// MeteringPoint is finer than a work centre (a measurement point, often on a
// single asset), so it stays a direct subclass of Location.
MATCH (core:Class {name: 'Location'})
MATCH (c:Class) WHERE c.name IN ['MeteringPoint']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 2. Utility equipment  (SUBCLASS_OF core Equipment)
// ============================================================
// The utility assets attach directly to the core Equipment class. There is no
// intermediate UtilityEquipment parent: the :Energy label and the /energy/ URI
// namespace already carry which domain owns an asset.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyMeter'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyMeter',
    c.description = 'A meter that measures consumption of an energy carrier such as steam, gas or compressed air at a metering point.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/PowerMeter'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'PowerMeter',
    c.description = 'An electrical meter that measures active power, demand and energy drawn by a load or the whole plant.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/Boiler'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'Boiler',
    c.description = 'A fired vessel that raises steam for the cook kettles, buffer tanks and clean-in-place circuits.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/CoolingSystem'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'CoolingSystem',
    c.description = 'A chiller and cooling-water plant that removes heat from hot-filled product and process equipment.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/CompressedAirSystem'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'CompressedAirSystem',
    c.description = 'A compressor and receiver plant that supplies compressed air to pneumatic actuators and packaging machinery.',
    c.version = '1.0.0';

// CoolingSystem and CompressedAirSystem above name whole utility PLANTS. The
// three classes below name the individual UNITS that make one up, because that
// is the level at which the floor commissions and meters an asset: the cooling
// water work centre publishes a cooling tower, not "the cooling system". Both
// tiers are Equipment; the plant reaches its units through the work centre that
// contains them, not through the class hierarchy.

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/Compressor'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'Compressor',
    c.description = 'A machine that raises air or gas pressure. The generating unit inside a CompressedAirSystem.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/CoolingTower'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'CoolingTower',
    c.description = 'An evaporative heat-rejection unit that returns heat from the cooling-water loop to atmosphere. The rejecting unit inside a CoolingSystem.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/HeatExchanger'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'HeatExchanger',
    c.description = 'A unit that transfers heat between two fluid streams without mixing them — here raising hot water from steam for the clean-in-place circuits.',
    c.version = '1.0.0';

// The utility assets are Equipment.
MATCH (core:Class {name: 'Equipment'})
MATCH (c:Class) WHERE c.name IN [
  'EnergyMeter', 'PowerMeter', 'Boiler', 'CoolingSystem', 'CompressedAirSystem',
  'Compressor', 'CoolingTower', 'HeatExchanger' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 3. Energy carriers  (SUBCLASS_OF PhysicalEntity, via EnergyCarrier)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyCarrier'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyCarrier',
    c.description = 'A medium that delivers usable energy to a process. Abstract parent of the carriers distributed around the plant.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/Electricity'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'Electricity',
    c.description = 'Electrical power drawn from the grid to run motors, meters, controls and packaging machinery.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/Steam'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'Steam',
    c.description = 'Boiler-raised steam that carries heat to the cook kettles, buffer-tank jackets and clean-in-place circuits.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/CompressedAir'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'CompressedAir',
    c.description = 'Pressurised air distributed to drive pneumatic valves, actuators and packaging-line devices.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/CoolingWater'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'CoolingWater',
    c.description = 'Chilled water circulated to remove heat from hot-filled product and process equipment.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'EnergyCarrier'}), (core:Class {name: 'PhysicalEntity'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'EnergyCarrier'})
MATCH (c:Class) WHERE c.name IN [
  'Electricity', 'Steam', 'CompressedAir', 'CoolingWater' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 4. Processes  (SUBCLASS_OF Process, via EnergyProcess)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyProcess'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyProcess',
    c.description = 'A step of work that measures or manages energy use. Abstract parent of the metering and demand-management steps.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyMetering'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyMetering',
    c.description = 'Reading and recording consumption of an energy carrier at a metering point.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/DemandManagement'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'DemandManagement',
    c.description = 'Coordinating loads to keep electrical demand below a target and avoid demand-charge penalties.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/LoadShedding'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'LoadShedding',
    c.description = 'Deliberately curtailing non-critical loads to bring demand back under the limit.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'EnergyProcess'}), (core:Class {name: 'Process'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'EnergyProcess'})
MATCH (c:Class) WHERE c.name IN [
  'EnergyMetering', 'DemandManagement', 'LoadShedding' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 5. Operational entities  (SUBCLASS_OF OperationalEntity)
// The contracts, budgets and reports that govern energy cost.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyTariff'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyTariff',
    c.description = 'The utility rate schedule that prices energy by time of use, setting peak and off-peak unit costs.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/DemandChargeRate'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'DemandChargeRate',
    c.description = 'The rate applied to peak electrical demand, billed on the highest interval demand within a period.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyBudget'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyBudget',
    c.description = 'The planned allowance of energy cost or consumption for a plant, area or period.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyReport'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyReport',
    c.description = 'A reported summary of energy consumption, cost and intensity over a period.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'OperationalEntity'})
MATCH (c:Class) WHERE c.name IN [
  'EnergyTariff', 'DemandChargeRate', 'EnergyBudget', 'EnergyReport' ]
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 6. Agents  (SUBCLASS_OF Agent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyManager'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyManager',
    c.description = 'A person accountable for energy cost and efficiency across the plant utilities.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyMonitoringSystem'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyMonitoringSystem',
    c.description = 'The software that collects meter readings, tracks demand and reports energy performance.',
    c.version = '1.0.0';

MATCH (core:Class {name: 'Agent'})
MATCH (c:Class) WHERE c.name IN ['EnergyManager', 'EnergyMonitoringSystem']
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

// ============================================================
// 8. Events  (SUBCLASS_OF Event, via EnergyEvent)
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/EnergyEvent'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'EnergyEvent',
    c.description = 'An operationally significant occurrence in energy operations. Abstract parent of the demand and metering events.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/PeakDemandReached'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'PeakDemandReached',
    c.description = 'Electrical demand set a new peak within the billing period.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/TariffChanged'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'TariffChanged',
    c.description = 'The applicable energy rate switched, such as a move from off-peak to peak pricing.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/DemandLimitExceeded'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'DemandLimitExceeded',
    c.description = 'Measured demand rose above the target limit, prompting load shedding.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/MeterReadingTaken'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'MeterReadingTaken',
    c.description = 'A reading of consumption was captured from a meter at a metering point.',
    c.version = '1.0.0';

MATCH (p:Class {name: 'EnergyEvent'}), (core:Class {name: 'Event'})
MERGE (p)-[:SUBCLASS_OF]->(core);

MATCH (p:Class {name: 'EnergyEvent'})
MATCH (c:Class) WHERE c.name IN [
  'PeakDemandReached', 'TariffChanged', 'DemandLimitExceeded', 'MeterReadingTaken' ]
MERGE (c)-[:SUBCLASS_OF]->(p);


// ============================================================
// 9. States  (SUBCLASS_OF State)
// Tariff periods that govern the cost of energy over time.
// ============================================================

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/PeakPeriod'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'PeakPeriodState',
    c.description = 'A time window in which energy is priced at the peak rate and demand charges apply.',
    c.version = '1.0.0';

MERGE (c:Class {uri: 'http://industry40.tv/ontology/energy/OffPeakPeriod'})
ON CREATE SET c.created_at = datetime()
SET c:Energy, c.name = 'OffPeakPeriodState',
    c.description = 'A time window in which energy is priced at the reduced off-peak rate.',
    c.version = '1.0.0';

// Deliberately unscoped. A tariff period is a condition of TIME, not of an
// equipment, process, order or material, so it has no lifecycle owner among
// the state scopes and stays a direct child of State.
MATCH (core:Class {name: 'State'})
MATCH (c:Class) WHERE c.name IN ['PeakPeriodState', 'OffPeakPeriodState']
MERGE (c)-[:SUBCLASS_OF]->(core);


// ============================================================
// 10. Specialised relationships  (SPECIALIZES a core relationship)
// Each also carries its own, narrower HAS_DOMAIN / HAS_RANGE.
// ============================================================

// --- specialisation of AFFECTS (Process/Event -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/energy/rel/CONSUMES_ENERGY'})
ON CREATE SET r.created_at = datetime()
SET r:Energy, r.name = 'CONSUMES_ENERGY',
    r.description = 'A process draws an energy carrier such as electricity or steam. Specialises AFFECTS.',
    r.version = '1.0.0';

// --- specialisation of PARTICIPATES_IN (Entity -> Entity) ---
MERGE (r:Relationship {uri: 'http://industry40.tv/ontology/energy/rel/METERED_BY'})
ON CREATE SET r.created_at = datetime()
SET r:Energy, r.name = 'METERED_BY',
    r.description = 'An energy carrier or process is measured by a meter. Specialises PARTICIPATES_IN.',
    r.version = '1.0.0';

// SPECIALIZES wiring (child relationship -> parent relationship)
MATCH (parent:Relationship {name: 'AFFECTS'})
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES_ENERGY']
MERGE (r)-[:SPECIALIZES]->(parent);

MATCH (parent:Relationship {name: 'PARTICIPATES_IN'})
MATCH (r:Relationship) WHERE r.name IN ['METERED_BY']
MERGE (r)-[:SPECIALIZES]->(parent);

// Domain wiring (the "from" side)
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES_ENERGY']
MATCH (c:Class {name: 'Process'})
MERGE (r)-[:HAS_DOMAIN]->(c);

// Named explicitly rather than through an Entity supertype, which the core
// no longer defines. METERED_BY specialises PARTICIPATES_IN, so its domain
// must not be wider than that relationship's: PhysicalEntity and Agent, not
// OperationalEntity.
MATCH (r:Relationship) WHERE r.name IN ['METERED_BY']
MATCH (c:Class) WHERE c.name IN ['PhysicalEntity', 'Agent']
MERGE (r)-[:HAS_DOMAIN]->(c);

// Range wiring (the "to" side)
MATCH (r:Relationship) WHERE r.name IN ['CONSUMES_ENERGY', 'METERED_BY']
MATCH (c:Class {name: 'PhysicalEntity'})
MERGE (r)-[:HAS_RANGE]->(c);
