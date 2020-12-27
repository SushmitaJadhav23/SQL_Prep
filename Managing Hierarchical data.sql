CREATE DATABASE HIERARCHY;
USE HIERARCHY;
-- http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- Dealing with Hierarchical Data in MySQL
-- The Adjacency List Model

CREATE TABLE category(
        category_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(20) NOT NULL,
        parent INT DEFAULT NULL
);

INSERT INTO category VALUES(1,'ELECTRONICS',NULL),(2,'TELEVISIONS',1),(3,'TUBE',2),
        (4,'LCD',2),(5,'PLASMA',2),(6,'PORTABLE ELECTRONICS',1),(7,'MP3 PLAYERS',6),(8,'FLASH',7),
        (9,'CD PLAYERS',6),(10,'2 WAY RADIOS',6);
        
SELECT * FROM category ORDER BY category_id;

-- 1) Retrieving a full tree
SELECT
	t1.name AS level1,
    t2.name AS level2,
    t3.name AS level3,
    t4.name AS level4
FROM category t1 LEFT JOIN category t2
ON t2.parent = t1.category_id
LEFT JOIN category t3
ON t3.parent = t2.category_id
LEFT JOIN category t4
ON t4.parent = t3.category_id 
WHERE t1.name = 'ELECTRONICS';

-- 2) Finding all the leaf nodes
SELECT t1.name
FROM category t1 LEFT JOIN category t2
ON t2.parent = t1.category_id
WHERE t2.parent IS NULL;

-- 3) Retrieving a single path
SELECT
	t1.name AS level1,
    t2.name AS level2,
    t3.name AS level3,
    t4.name AS level4
FROM category t1 LEFT JOIN category t2
ON t2.parent = t1.category_id
LEFT JOIN category t3
ON t3.parent = t2.category_id
LEFT JOIN category t4
ON t4.parent = t3.category_id 
WHERE t1.name = 'ELECTRONICS' AND t4.name = 'Flash';

-- Limitations
-- Before being able to see the full path of a category we have to know the level at which it resides

-- The Nested Set Model
CREATE TABLE nested_category (
        category_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(20) NOT NULL,
        lft INT NOT NULL,
        rgt INT NOT NULL
);

INSERT INTO nested_category VALUES(1,'ELECTRONICS',1,20),(2,'TELEVISIONS',2,9),(3,'TUBE',3,4),
 (4,'LCD',5,6),(5,'PLASMA',7,8),(6,'PORTABLE ELECTRONICS',10,19),(7,'MP3 PLAYERS',11,14),(8,'FLASH',12,13),
 (9,'CD PLAYERS',15,16),(10,'2 WAY RADIOS',17,18);

SELECT * FROM nested_category ORDER BY category_id;

-- RETRIEVING A FULL TREE

SELECT node.name
FROM nested_category AS node,
        nested_category AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND parent.name = 'ELECTRONICS'
ORDER BY node.lft;

-- FINDING ALL THE LEAF NODES

SELECT
	name
FROM nested_category
WHERE rgt = lft + 1;

-- Retrieving a single path
SELECT parent.name
FROM nested_category AS node, 
	 nested_category AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
AND node.name = 'Flash'
ORDER BY parent.lft;