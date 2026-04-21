# IMOS THREDDS Docker

A Docker-based THREDDS Data Server for [IMOS (Integrated Marine Observing System)](https://imos.org.au/) - Australia's national ocean observation network.

## What is THREDDS?

THREDDS (Thematic Real-time Environmental Distributed Data Services) is a web server that provides access to scientific datasets through multiple protocols:

- **OpenDAP/DAP4** - Programmatic data access
- **WMS** - Web Mapping Service for visualization
- **WCS** - Web Coverage Service for gridded data
- **HTTP** - Direct file downloads
- **NetCDF Subset Service** - Data subsetting

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Docker Container (unidata/thredds-docker:5.6)  │
├─────────────────────────────────────────────────┤
│  • THREDDS Server (Tomcat + Java)               │
│  • Custom configuration files                   │
├─────────────────────────────────────────────────┤
│  Data Source:                                    │
│  • S3 bucket: imos-data (25+ datasets)          │
│  • Direct access via cdms3:// protocol          │
└─────────────────────────────────────────────────┘
```

## Project Structure

```
imos-thredds-docker/
├── Dockerfile                    # Docker image definition
├── docker-compose.yml            # Local deployment config
├── compose.env                   # Environment variables
├── config/
│   ├── catalog.xml               # Data catalog and dataset definitions
│   ├── threddsConfig.xml         # THREDDS server configuration
│   └── wmsConfig.xml             # WMS service styling configuration
├── assets/
│   ├── logo.png                  # IMOS logo
│   └── threddsIcon.gif           # THREDDS icon
└── .github/
    ├── workflows/                # CI/CD pipeline definitions
    └── environment/              # Deployment environment configs
```

## Key Components

| Component                  | Purpose                                                  |
| -------------------------- | -------------------------------------------------------- |
| `Dockerfile`               | Extends Unidata THREDDS with custom config               |
| `config/catalog.xml`       | Defines 25+ datasets from AIMS, CSIRO, BoM, universities |
| `config/threddsConfig.xml` | Server settings (4GB heap, 40GB cache)                   |
| `config/wmsConfig.xml`     | WMS visualization styling for oceanographic variables    |

## Configuration Files

### catalog.xml - Data Catalog

Defines what datasets are available and how to access them.

| Element         | Description                                              |
| --------------- | -------------------------------------------------------- |
| `<service>`     | Defines access protocols (OpenDAP, WMS, WCS, HTTP, etc.) |
| `<datasetScan>` | Scans a directory/S3 path for datasets                   |

**Key sections:**

```xml
<!-- Defines all available services -->
<service name="regGriddedServices" serviceType="compound">
  <service name="odap" serviceType="OpenDAP" ... />
  <service name="wms" serviceType="WMS" ... />
  ...
</service>

<!-- All datasets accessed directly from S3 via cdms3 protocol -->
<datasetScan name="IMOS_AusTemp"
  location="cdms3:imos-data?IMOS/SRS/AusTemp/ssta/#delimiter=/" ... />

<datasetScan name="AIMS"
  location="cdms3:imos-data?AIMS/#delimiter=/" ... />
```

The file defines **25+ data sources** from various organizations (AIMS, CSIRO, BoM, universities, etc.).

### threddsConfig.xml - Server Configuration

Controls THREDDS server behavior, caching, and enabled services.

| Section                 | Purpose                                 |
| ----------------------- | --------------------------------------- |
| `<serverInformation>`   | Branding - name, logo, contact info     |
| `<DiskCache>`           | Temp file storage (40GB max)            |
| `<NetcdfFileCache>`     | Open file limits (200-400 files)        |
| `<HTTPFileCache>`       | HTTP range request cache (20-40 files)  |
| `<AggregationCache>`    | Cache for joined datasets (30 days max) |
| `<NetcdfSubsetService>` | Enable/disable subsetting               |
| `<WMS>`                 | WMS settings (max 2048x2048 images)     |

**Cache Types Explained:**

| Cache                | What it does                                                     | Purpose                                          |
| -------------------- | ---------------------------------------------------------------- | ------------------------------------------------ |
| `<DiskCache>`        | Stores temporary files (uncompressed data, intermediate results) | Speed up repeated operations on compressed files |
| `<NetcdfFileCache>`  | Keeps NetCDF file handles open in memory                         | Avoid reopening files repeatedly                 |
| `<HTTPFileCache>`    | Caches HTTP range request data                                   | Speed up partial file downloads                  |
| `<AggregationCache>` | Caches aggregated dataset metadata                               | Speed up access to joined datasets               |

**Example settings:**

```xml
<DiskCache>
  <maxSize>40 Gb</maxSize>
</DiskCache>

<WMS>
  <allow>true</allow>
  <maxImageWidth>2048</maxImageWidth>
  <maxImageHeight>2048</maxImageHeight>
</WMS>
```

### wmsConfig.xml - WMS Visualization Styling

Controls how data appears in WMS map images (colors, scales, palettes).

| Section           | Purpose                                         |
| ----------------- | ----------------------------------------------- |
| `<defaults>`      | Global defaults (palette, opacity, color range) |
| `<standardNames>` | Styles by CF standard variable names            |
| `<overrides>`     | Dataset-specific styling overrides              |

**Example:**

```xml
<!-- Default for sea surface temperature -->
<standardName name="sea_surface_temperature" units="K">
  <defaultColorScaleRange>268 310</defaultColorScaleRange>
</standardName>

<!-- Override for specific CSIRO dataset -->
<datasetPath pathSpec="CSIRO/Climatology/CARS/2009/*.nc">
  <variable id="TEMP">
    <defaultColorScaleRange>-1.9 38</defaultColorScaleRange>
  </variable>
  <variable id="TEMP_anomaly">
    <defaultPaletteName>redblue</defaultPaletteName>
  </variable>
</datasetPath>
```

This ensures oceanographic variables display with appropriate color scales (e.g., temperature in Kelvin, wave heights in meters, directions as 0-360 degrees).

### Configuration Summary

| File                | What              | Why                           |
| ------------------- | ----------------- | ----------------------------- |
| `catalog.xml`       | Dataset inventory | "What data is available?"     |
| `threddsConfig.xml` | Server settings   | "How does the server behave?" |
| `wmsConfig.xml`     | Map styling       | "How do maps look?"           |

## Data Flow

All datasets (including AusTemp) are accessed directly from S3 using the `cdms3://` protocol:

```
Client Request
      ↓
CloudFront CDN (cache hit?) ──→ Return cached tile (fast, ~50ms)
      ↓ (cache miss)
THREDDS Server
      ↓
S3 Bucket (via cdms3:// protocol)
      ↓
Generate WMS tile → Cache in CloudFront → Return to client
```

**Benefits of direct S3 access:**

- No local storage needed
- Always up-to-date data
- Simpler architecture (no cron jobs)
- S3 ↔ ECS in same AWS region is fast (~10-50ms)

## Local Development

### Prerequisites

- Docker
- Docker Compose

### Running Locally

```bash
# Start the development server on port 7070
docker-compose up --build thredds-imos

# Or start the production configuration on ports 80/443
docker-compose up --build thredds-imos-prod
```

Access the THREDDS catalog at: http://localhost:7070/thredds/catalog.html

## CI/CD Pipeline

The project uses GitHub Actions with three AWS environments:

| Environment | AWS Account  | Purpose                                         |
| ----------- | ------------ | ----------------------------------------------- |
| central     | 851725428481 | Build account - builds and pushes Docker images |
| edge        | 704910415367 | Edge/staging environment for testing            |
| production  | 211125304466 | Live THREDDS service                            |

### Deployment Flow

```
Push to main branch
        ↓
Build Docker image → Push to ECR
        ↓
Deploy to edge environment

Version tag (v*.*.*)
        ↓
Build Docker image → Push to ECR
        ↓
Deploy to production environment
```

Authentication uses GitHub OIDC (no hardcoded credentials).

## Configuration

### Environment Variables

| Variable           | Default | Description                   |
| ------------------ | ------- | ----------------------------- |
| `THREDDS_XMX_SIZE` | 4G      | Maximum Java heap for THREDDS |
| `THREDDS_XMS_SIZE` | 4G      | Initial Java heap for THREDDS |
| `TDM_XMX_SIZE`     | 6G      | Maximum Java heap for TDM     |
| `TDM_XMS_SIZE`     | 1G      | Initial Java heap for TDM     |
| `TOMCAT_USER_ID`   | 1000    | Tomcat user ID                |
| `TOMCAT_GROUP_ID`  | 1000    | Tomcat group ID               |

### Server Settings

Key settings in `threddsConfig.xml`:

- **Disk cache**: 40GB maximum
- **NetCDF file cache**: 200-400 open files
- **WMS max dimensions**: 2048x2048

## Data Sources

The catalog includes 25+ datasets from various organizations:

- **AIMS** - Australian Institute of Marine Science
- **Bureau of Meteorology**
- **CSIRO**
- **Australian universities** (UWA, UNSW, UTas, etc.)
- **State governments** (NSW, SA, QLD, WA, Vic)
- **New Zealand partners**

## License

See [LICENSE](LICENSE) for details.
