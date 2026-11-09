# README artwork

Original illustrations generated on 2026-11-09 using the built-in OpenAI `image_gen.imagegen` tool. The tool did not disclose the underlying model identifier. No official game artwork, logos, or device screenshots were used as inputs.

| File | Dimensions | PNG size | Use |
|---|---|---|---|
| `concept-banner.png` | 1600 × 600 | 1.37 MiB | README cover |
| `mockup-countdown.png` | 1600 × 1000 | 1.46 MiB | Main-screen concept |
| `mockup-live-activity.png` | 1600 × 1000 | 1.50 MiB | Lock Screen and Dynamic Island concepts |
| `concept-milestones.png` | 1600 × 800 | 1.16 MiB | Five local notification milestones |

These files are **AI-generated concepts, not screenshots**. Layouts, wording, materials, glyphs, and system presentation are illustrative and can differ from the implemented app. They do not demonstrate successful device validation or extension loading. Historical mockups in `../mockups/` remain separate from this README artwork set.

The palette follows the existing sunset direction: deep purple, magenta, orange, cream text, original palms, skyline, and water. The example countdown is frozen at 19 days and 12:22:41, equivalent to 468:22:41 in total hours. No absolute release date is embedded; `ReleaseConfig` remains the only configuration source and its date remains unverified.

Each asset was generated separately. Final RGB PNGs were resized to the delivery dimensions with Lanczos resampling and losslessly PNG-optimized with Pillow; no cropping, compositing, or UI/text retouching was applied. All four files are below 2 MB each. They share an intended 800 px README display width, with twice that horizontal resolution for sharp displays; GitHub can scale them down to fit its content column.

The exact prompt for each image, generation tool, date, intended dimensions, and purpose are stored in [`generation-prompts.json`](generation-prompts.json). Original generated files were retained in the local Codex generation directory; all deliverables used by the README are committed here.
