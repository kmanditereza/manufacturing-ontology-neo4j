// 1. Places — instances of Site, PackagingArea and PackagingLine, nested with CONTAINS
MATCH (siteCls:Class {name: 'Site'}), (areaCls:Class {name: 'PackagingArea'}), (lineCls:Class {name: 'PackagingLine'})
MERGE (site:Instance {id: 'SITE-MUC'})            SET site.name = 'Munich Plant'
MERGE (area:Instance {id: 'AREA-MUC-PKG'})        SET area.name = 'Packaging Area'
MERGE (line:Instance {id: 'WC-MUC-PKG-L1'})       SET line.name = 'Packaging Line 1'
MERGE (site)-[:IS_INSTANCE_OF]->(siteCls)
MERGE (area)-[:IS_INSTANCE_OF]->(areaCls)
MERGE (line)-[:IS_INSTANCE_OF]->(lineCls)
MERGE (site)-[:CONTAINS]->(area)
MERGE (area)-[:CONTAINS]->(line);

// 2. A machine — an instance of Equipment, classified by a catalogue entry, located on the line
MATCH (eqCls:Class {name: 'Equipment'}), (ecCls:Class {name: 'EquipmentClass'}),
      (line:Instance {id: 'WC-MUC-PKG-L1'})
MERGE (filler:Instance {id: 'EQ-FL-501'})         SET filler.name = 'Filler FL-501'
MERGE (fillerType:Instance {id: 'EQCLASS-FILLER'}) SET fillerType.name = 'Filler'
MERGE (filler)-[:IS_INSTANCE_OF]->(eqCls)
MERGE (fillerType)-[:IS_INSTANCE_OF]->(ecCls)
MERGE (filler)-[:IS_OF_CLASS]->(fillerType)
MERGE (filler)-[:IS_LOCATED_AT]->(line);
//

// 3. Work happening — an instance of the Filling process, on the line, with the filler taking part
MATCH (fillingCls:Class {name: 'Filling'}),
      (line:Instance {id: 'WC-MUC-PKG-L1'}), (filler:Instance {id: 'EQ-FL-501'})
MERGE (run:Instance {id: 'RUN-FILL-0001'})        SET run.name = 'Filling run 0001'
MERGE (run)-[:IS_INSTANCE_OF]->(fillingCls)
MERGE (run)-[:OCCURS_AT]->(line)
MERGE (filler)-[:PARTICIPATES_IN]->(run);




MATCH p=(:Instance)-[]->() RETURN p
