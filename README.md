# Data Warehouse & Analytics Solution

## Overview

This repository contains an end-to-end Data Warehouse and Analytics project built with SQL Server. The objective is to demonstrate the complete process of transforming raw business data into a structured analytical model that supports reporting and business intelligence.

The project serves as a hands-on portfolio example of modern data engineering practices, covering data ingestion, transformation, warehouse design, and analytical reporting.

---

## Project Goals

The primary objectives of this project are to:

- Build a scalable SQL Server data warehouse.
- Integrate data from multiple business systems.
- Clean and transform raw datasets into reliable analytical data.
- Design an optimized dimensional model for reporting.
- Generate meaningful business insights using SQL.

---

## Data Warehouse Architecture

This project follows the **Medallion Architecture**, which organizes data into three processing layers.

### Bronze Layer
- Stores raw data exactly as received from the source systems.
- CSV files are imported directly into SQL Server without modification.
- Acts as the initial landing zone for incoming data.

### Silver Layer
- Applies data cleansing and validation.
- Standardizes formats and resolves quality issues.
- Prepares consistent datasets for downstream processing.

### Gold Layer
- Contains business-ready data.
- Implements a Star Schema with fact and dimension tables.
- Optimized for reporting, dashboarding, and analytical queries.

---

## Project Components

The solution includes several core stages:

### Data Warehouse Design
- Designing a modern warehouse using the Medallion Architecture.
- Structuring data into Bronze, Silver, and Gold layers.

### ETL Development
- Extracting data from ERP and CRM source systems.
- Transforming and validating records.
- Loading processed data into the warehouse.

### Dimensional Modeling
- Creating fact and dimension tables.
- Designing an efficient schema for business reporting.

### Analytics
- Writing SQL queries to analyze business performance.
- Producing datasets suitable for dashboards and reports.

---

## Skills Demonstrated

This project showcases practical experience in:

- SQL Development
- Data Warehousing
- ETL Process Development
- Data Engineering
- Data Modeling
- Data Analytics
- Database Design

---

## Tools Used

The project was developed using the following technologies:

- SQL Server Express
- SQL Server Management Studio (SSMS)
- Git & GitHub
- Draw.io
- Notion
- CSV datasets

---

## Project Requirements

### Objective

Develop a centralized SQL Server data warehouse that consolidates sales information from multiple operational systems into a single analytical platform for reporting and decision-making.

### Functional Requirements

#### Data Sources
- Import datasets from ERP and CRM systems provided as CSV files.

#### Data Preparation
- Identify and resolve data quality issues.
- Standardize and clean records before loading into analytical tables.

#### Data Integration
- Merge multiple data sources into a unified dimensional model.
- Ensure the resulting schema is optimized for business analysis.

#### Scope
- Process only the latest available dataset.
- Historical tracking and slowly changing dimensions are outside the project scope.

#### Documentation
- Document the warehouse architecture and data model.
- Provide sufficient information for both technical teams and business users.

---

## Repository Purpose

This repository demonstrates the complete workflow involved in building a modern data warehouse, from raw data ingestion through ETL processing and dimensional modeling to analytics-ready datasets.

It is intended as a portfolio project to showcase practical SQL and data engineering skills while following commonly used industry practices.

## 👋 About Me

Hi, I'm **[Ahamadullah Thasneem]**.

I'm an aspiring Data Engineer who enjoys turning raw, messy data into structured systems that people can actually use. Most of my time is spent learning SQL, data warehousing, ETL development, and analytics by building projects instead of just reading about them.

This repository is part of that journey. Every project I complete teaches me something new, whether it's designing better data models, writing cleaner SQL, or understanding how modern data platforms are built.
