# Mechanical hardware

Store native CAD files, drawings, assembly references, and fabrication files here. Use clear part names and revision identifiers. State the CAD software/version and any material, tolerance, or manufacturing notes needed by collaborators.


# Mechanical Hardware — Bus Swing-Plug Door Mechanism

This directory contains the 3D CAD assembly, 2D engineering drawings, and 3D printing preparation files for the **Bus Swing-Plug Door Mechanism**. All mechanical components were designed and assembled in **Autodesk Fusion 360**.

## Design & Prototype Overview

| 3D CAD Assembly (Fusion 360) | Assembled Physical Prototype |
| :---: | :---: |
| https://github.com/user-attachments/assets/c4239aec-4497-4974-a7ec-507210626183 | <img width="369.333" height="492.333" alt="S__27099147" src="https://github.com/user-attachments/assets/da759811-e155-4daf-80ce-94a61eba41c9" />|

### Mechanism Operation Demo

https://github.com/user-attachments/assets/f35bace8-fe9f-4325-a478-3a5b4ff61085


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
* **Slicer Profile (Bambu Studio):**
  * **Layer Height:** 0.12 mm
  * **Wall Loops:** 2
  * **Infill Density:** 15.0%
* **Build Layout:** 4 Build Plates (Total estimated print time: ~8h 38m)
* <img width="172" height="173" alt="Screenshot 2026-11-21 011543" src="https://github.com/user-attachments/assets/e529b95b-79fb-4292-bafd-3521ed52af57" />

* **Hardware & Fasteners:** M3 machine screws, M3 hex nuts, and a 6 mm external retaining ring (refer to `bom.csv` for exact quantities).

---

## Manufacturing & Assembly Notes

### 1. Support Structure Optimization (Linkage / Driving Rod — Plate 3)
During the initial slice and test print of the curved linkage and driving rod assembly (`rod` / `redo v19-SOLID-7`), **Tree Supports (`tree(auto)`)** with a **0.12 mm** Top/Bottom Z distance were used. Because the tree branches only contacted sparse points along the inclined and curved bars—and the tight 0.12 mm Z-gap bonded too closely to the underside—the resulting surface was rough with noticeable sagging.

* **Resolution:** Switched the support type to **Normal Support (`normal(auto)`)** and increased both **Top Z distance** and **Bottom Z distance** to **0.18 mm** in Bambu Studio. This provided continuous, uniform support underneath the entire length of the inclined linkage bars while allowing clean support removal and a smooth surface finish.

| Stage | Object/Part Support Settings | Sliced Preview (Plate 03) |
| :--- | :---: | :---: |
| **Attempt 1 (Initial):**<br>`tree(auto)`<br>Top/Bottom Z distance: `0.12 mm` | <img width="640" height="359" alt="Screenshot 2026-11-21 010643" src="https://github.com/user-attachments/assets/83d4d150-fdde-44f5-84c2-abd7274f4fa4" />
 | <img width="332" height="227" alt="Screenshot 2026-11-21 010810" src="https://github.com/user-attachments/assets/271ecb58-4578-4f5f-83f1-0f0f36ef92fe" />|
| **Attempt 2 (Final):**<br>`normal(auto)`<br>Top/Bottom Z distance: `0.18 mm` | <img width="640" height="359" alt="Screenshot 2026-11-21 010943" src="https://github.com/user-attachments/assets/0d272fec-e34e-4e8f-b58d-c70bd9c8067d" />
 | <img width="340" height="231" alt="Screenshot 2026-11-21 011020" src="https://github.com/user-attachments/assets/b224e619-4dd7-4569-8135-9532adf3e25f" />|

### 2. Fastener Retention at Revolute Joints (Double-Nut Locking)
Several revolute joints in the linkage mechanism are fastened using M3 screws and hex nuts. During repeated manual actuation and cyclic testing, friction at the rotating joints caused single nuts to gradually back off and loosen.

* **Resolution:** Implemented a **double-nut (jam-nut) locking method** by stacking a second M3 hex nut tightly against the primary nut at each revolute joint. This prevented thread loosening while maintaining smooth rotational clearance for the links.
