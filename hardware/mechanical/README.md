# Mechanical hardware

Store native CAD files, drawings, assembly references, and fabrication files here. Use clear part names and revision identifiers. State the CAD software/version and any material, tolerance, or manufacturing notes needed by collaborators.

# Mechanical Hardware — Bus Swing-Plug Door Mechanism

This directory contains the 3D CAD assembly, 2D engineering drawings, and 3D printing preparation files for the **Bus Swing-Plug Door Mechanism**. All mechanical components were designed and assembled in **Autodesk Fusion 360**.

![Full CAD Assembly](images/assembly-overview.png)
*(Replace the link above with your Fusion 360 assembly screenshot)*

---

## Repository Contents & How to Open

| File Name | Format | Description & Usage |
| :--- | :--- | :--- |
| `Bus Swing-Plug Door Mechanism.step` | STEP (`.step`) | Neutral 3D CAD assembly file containing all structural and linkage components. Can be opened in **Autodesk Fusion 360**, SolidWorks, Onshape, or any standard CAD software. |
| `Bus Swing-Plug Door Mechanism Drawing.pdf` | PDF (`.pdf`) | 2D engineering drawings with orthographic views, critical dimensions, and hole tolerances for inspection and reference. |
| `Bus Swing-Plug Door Mechanism Bambulab X1C 4plate.3mf` | Generic 3MF (`.3mf`) | Multi-plate print layout (4 plates) pre-arranged for a **Bambu Lab X1C** (Textured PEI Plate). Open in **Bambu Studio** or **OrcaSlicer** to inspect part orientations or customize print profiles. |
| `Bus Swing-Plug Door Mechanism.gcode.3mf` | Sliced 3MF (`.gcode.3mf`) | Ready-to-print sliced G-code package for all 4 build plates on the Bambu Lab X1C. |
| `bom.csv` | CSV (`.csv`) | Bill of Materials listing filament consumption by color, standard fasteners, and estimated costs. |

---

## Fabrication Specifications

* **CAD Software:** Autodesk Fusion 360
* **3D Printer:** Bambu Lab X1C (Bambu Textured PEI Plate)
* **Material:** 1.75 mm PLA Filament (Black, Pink, White, Red)
* **Build Layout:** 4 Build Plates (Total estimated print time: ~8h 38m)
* **Hardware & Fasteners:** M3 machine screws, M3 hex nuts, and a 6 mm external retaining ring (refer to `bom.csv` for exact quantities).

---

## Manufacturing & Assembly Notes

### 1. Support Structure Optimization (Linkage / Driving Rod)
During initial test prints of the curved linkage and driving rod assembly (`rod`), **Tree Supports** were used. However, this resulted in insufficient support contact along the horizontal and curved overhangs, causing surface roughness and slight sagging on the underside.

* **Resolution:** Switched the support type from *Tree* to **Normal Support** in Bambu Studio, which provided uniform support beneath the cylindrical rod sections and yielded a smooth, dimensionally accurate surface finish.

| Slicer Support Settings | Sliced Preview (Bambu Studio) |
| :---: | :---: |
| ![Slicer Settings](images/slicer-settings.png) | ![Sliced Preview](images/sliced-preview.png) |

### 2. Fastener Retention at Revolute Joints (Double-Nut Locking)
Several revolute joints in the linkage mechanism are fastened using M3 screws and hex nuts. During repeated manual actuation and cyclic testing, friction at the rotating joints caused single nuts to gradually back off and loosen.

* **Resolution:** Implemented a **double-nut (jam-nut) locking method** by stacking a second M3 hex nut tightly against the primary nut at each revolute joint. This prevented thread loosening while maintaining smooth rotational clearance for the links.
