# Raksha / SwasthaGram — Reviewer Q&A Bank (~100 Qs with Answers)

Answers are written short and speakable (2-4 sentences) — read them once, then say them in your own words. Don't recite verbatim; judges notice memorized answers.

---

## A. General / Concept / Vision

**1. In one line, what problem does your project solve?**
Rural India has 1 doctor per 10,000+ people and no basic diagnostics at most PHCs — we built a handheld device that gives instant, AI-powered triage without needing a doctor present.

**2. Why did you choose this problem statement specifically?**
Healthcare access in rural India is a scale problem, not a knowledge problem — the diagnostic tools and AI models already exist individually; nobody has unified them into one offline-first device for frontline health workers.

**3. What makes your solution different from existing rural telemedicine kits?**
Most existing kits are fragmented Bluetooth peripherals (separate BP cuff, separate pulse-ox, separate apps) that need constant internet and still require a doctor to interpret results. We run the interpretation itself — Edge-AI triage — fully offline, on-device.

**4. Who is your primary user — the ASHA/ANM, or the patient?**
The ASHA/ANM operates the device; the patient is the beneficiary. The UI and workflow are designed entirely around the health worker's literacy and field conditions.

**5. What happens if the device has zero internet connectivity for a full day?**
Everything still works — sensing, AI inference, and triage all run locally on the Pi 4. Records queue in the offline-first database and sync automatically the next time Wi-Fi or mobile data is available.

**6. Why a single integrated device instead of separate certified medical instruments?**
Cost and workflow — a rural health worker doing dozens of patients a day can't carry and operate five separate certified devices with five different apps. Integration is what makes daily field use realistic.

**7. What's your device's name origin — why "Raksha" / "SwasthaGram"?**
"Raksha" means protection, and "SwasthaGram" combines "swastha" (health) and "gram" (village) — together they capture the mission: protecting village-level health.

**8. What is the single biggest risk to adoption of this device in the field?**
Trust — health workers and patients need to trust an AI triage call the same way they'd trust a doctor. That's exactly why we built the MEWS hard-rule safety net and confidence-score transparency, so the system is honest when it's unsure instead of quietly guessing.

**9. If you had to cut one sensor due to budget, which would you drop and why?**
The urine-strip colorimeter — it's the most environmentally sensitive (light interference) and lowest-acuity of the five; ECG, SpO2, and temperature cover more life-threatening conditions.

**10. What's the "wow factor" you want judges to remember after this pitch?**
That we didn't just build a sensor kit — we built the safety net around the AI. The MEWS override is the difference between a hackathon demo and something you'd actually trust with a real patient.

---

## B. Hardware & Sensors

**11. Why did you choose AD8232 for ECG instead of a clinical-grade ECG chip?**
Cost and availability — AD8232 is a proven, low-cost single-lead ECG front-end widely used in embedded projects. We compensate for its lack of clinical-grade noise rejection with software filtering and a hold-still capture protocol.

**12. AD8232 has no right-leg-drive — how do you handle motion artifacts from a seated, breathing patient?**
We apply a 0.5–40 Hz Butterworth bandpass plus a 50 Hz notch filter, and require a 10-15 second "hold still" capture window gated by the lead-off detection pins, discarding any segment where electrodes toggle loose.

**13. Why MAX9814 for the stethoscope mic — what's special about its AGC, and why is that a problem here?**
MAX9814 is a cheap, widely available electret mic amp with automatic gain control (AGC). The problem is AGC pumps up ambient room noise between heartbeats, masking the actual heart sounds — so we bypass the onboard AGC and use a fixed-gain stage instead.

**14. How do you separate stethoscope audio from spoken symptoms if using one microphone?**
We don't use one mic for both — that was a flaw in the original design. We use a second, separate microphone for speech, with a physical toggle so firmware knows which one is active.

**15. Walk us through your dual-microphone hardware fix.**
MAX9814 stays dedicated to the stethoscope chest-piece at fixed gain; a second MEMS mic captures open-air speech on its own ADC channel. A physical button lets the health worker switch between "Listen to chest" and "Record symptoms" modes, so the firmware always knows which buffer to trust.

**16. TCS3200 needs 5V but ESP32 GPIOs are 3.3V — how do you prevent damaging the board?**
We either power the TCS3200 at 3.3V directly (it supports 2.7–5.5V) or insert a cheap logic-level shifter between its output pin and the ESP32 GPIO — without this, the 5V signal risks frying the pin.

**17. How do you prevent ambient sunlight from corrupting the urine-strip color reading?**
A light-sealed housing/slot for strip insertion, calibrated against a white/black reference tile at the start of each session, and capturing color in RGB-ratio space rather than raw light frequency.

**18. Why is the ESP32's built-in ADC "non-linear," and how does that affect readings?**
The ESP32's SAR ADC is documented to be non-linear, especially near 0V and the reference voltage, and this varies chip to chip. Uncalibrated, absolute ECG or audio amplitude values become unreliable and don't generalize across devices.

**19. What is `esp_adc_cal` and why do you need it at boot?**
It's ESP32's built-in two-point calibration API that uses factory-programmed reference values in each specific chip to correct ADC readings — we call it once at startup so amplitude values are consistent across boards.

**20. How do you achieve IP54 protection for a monsoon/dusty environment?**
A sealed enclosure with rubber gaskets around openings, covered connector ports, and a wipeable acrylic window separating the color sensor from the strip slot — dust can't easily get in and light splashes won't reach the electronics.

**21. What's your battery runtime target, and how did you calculate it?**
We sum the current draw (mA) of every component from datasheets — ESP32, Pi 4, sensors — to size a Li-ion pack targeting at least a full field shift on one charge, tested empirically rather than just estimated.

**22. Why do you need a BMS — what happens without one?**
A Battery Management System protects against overcharging, over-discharging, and short-circuiting. Without it, a lithium battery pack is a genuine fire risk, especially in hot rural conditions.

**23. How do you sterilize the stethoscope diaphragm and urine-strip slot between patients?**
A detachable, wipeable/autoclavable diaphragm cover for the chest-piece, and a sealed acrylic window over the color sensor so the strip slot can be alcohol-wiped without touching electronics — plus a dedicated disposal chute for used strips.

**24. What's your total BOM cost per unit?**
[Fill in your actual costed BOM here — ESP32 (~₹500), AD8232 (~₹300), MAX9814 (~₹150), TCS3200 (~₹200), MAX30102 (~₹300), Pi 4 (~₹5000), enclosure/battery/misc — total ballpark ₹7,000–9,000 per unit; state your real number.]

**25. How do you calibrate the device across multiple units for consistency?**
Per-unit `esp_adc_cal` calibration at boot, session-start white/black reference calibration for the color sensor, and z-scored/normalized features (not raw ADC counts) fed into the AI models so results generalize across devices.

---

## C. Firmware & Embedded Systems

**26. Why FreeRTOS/interrupt-driven sampling instead of a simple `delay()` loop?**
A blocking `delay()` loop freezes the ESP32 during each wait, which breaks down once you're reading 5 sensors at different speeds simultaneously. FreeRTOS tasks let each sensor sample on its own independent schedule without blocking the others.

**27. What communication protocol do you use between ESP32 and Raspberry Pi, and why?**
Either a direct USB Serial link or MQTT over Wi-Fi — Serial is simple and reliable for a fixed physical setup, MQTT gives wireless flexibility when the two boards aren't hardwired together.

**28. How do you verify sensor data isn't corrupted in transit?**
Every packet includes a checksum calculated before sending; the receiver recalculates it and discards the packet if it doesn't match, rather than feeding corrupted data into the AI pipeline.

**29. What's your ECG sampling rate, and why that specific number?**
Roughly 200 Hz (every 5ms), which comfortably captures the QRS complex and heart-rate range while staying light enough for the ESP32 to sustain alongside the other four sensors.

**30. How do you detect if an ECG electrode has come loose mid-reading?**
The AD8232's LO+/LO- lead-off pins toggle when an electrode loses contact; our firmware gates on these pins and discards any segment where they fire, rather than feeding a corrupted signal to the CNN.

**31. What happens to sampling if one sensor is slower than others?**
FreeRTOS tasks run independently per sensor, so a slower sensor like the urine-strip colorimeter doesn't stall or drift the timing of faster sensors like ECG.

**32. How is your firmware power-optimized during idle periods?**
Sensors like AD8232 have a shutdown (SDN) pin we toggle to power them down when not actively sampling, reducing idle current draw and extending battery life.

**33. What toolchain/IDE did you use for ESP32 development?**
Arduino IDE for initial sensor bring-up (fast iteration), moving to ESP-IDF/FreeRTOS for the production firmware once we needed real interrupt-driven multitasking.

**34. How do you handle a sensor failure at runtime?**
Each sensor's task independently reports its own health; if a sensor drops out, the firmware flags that channel as unavailable rather than silently sending stale or zero data downstream.

**35. What's your plan if the Raspberry Pi crashes mid-patient-encounter?**
The app on the health worker's device keeps local state of the encounter in its offline-first database, so it can resume or restart the encounter without losing already-captured sensor data.

---

## D. AI / Machine Learning / Edge Inference

**36. Walk us through your full AI pipeline, sensor to triage output.**
Raw sensor streams are filtered and calibrated on the ESP32, sent to the Pi 4, where Whisper converts speech to text, IndicBERT extracts symptoms, two CNNs classify ECG and urine-strip data, and XGBoost combines everything into a final triage label with a confidence score.

**37. Why whisper.cpp instead of the standard Python Whisper package?**
whisper.cpp (ggml) is purpose-built to run efficiently on small ARM devices like a Raspberry Pi — the standard Python package is reported to be 5-10x slower on CPU, which is untenable for real-time use.

**38. Why one language for the hackathon, and how do you scale later?**
Multilingual ASR multiplies training and testing effort; we scoped to Hindi (or the pilot state's language) to hit hackathon timelines, with the architecture designed so additional languages are just additional model/audio assets, not a rebuild.

**39. What is IndicBERT/MuRIL doing, and why not just keyword-match?**
It performs Named Entity Recognition to pull structured symptoms ("fever," "chest pain") out of free-form spoken transcripts — more robust than keyword matching for natural speech, though we do keep a keyword-list fallback as a safety net.

**40. What datasets did you train your ECG CNN on, and what accuracy?**
The PhysioNet MIT-BIH Arrhythmia Database for baseline benchmarking; [insert your actual measured accuracy here] — we treat this as a Phase-1 baseline to improve against with more field data.

**41. How did you get training data for the urine-strip CNN?**
Public urine-strip color datasets (e.g., from Kaggle) for baseline training, supplemented with our own captures from the actual TCS3200 sensor to match real hardware characteristics.

**42. Why XGBoost for the final triage decision instead of a deep learning model?**
XGBoost handles small, tabular, heterogeneous inputs (symptoms + ECG result + urine result) well, trains fast on limited hackathon-scale data, and — critically — exposes a clean confidence score via `predict_proba()` that our safety layer depends on.

**43. What does your triage model output besides the label?**
A confidence score (0-100%) alongside the Green/Yellow/Red label, so downstream logic knows how much to trust the call.

**44. How do you prevent all 5 AI models from exceeding the Pi 4's RAM?**
We lazy-load models per pipeline stage instead of holding all five resident simultaneously, and quantize everything to INT8, which was the single biggest fix over the original all-loaded-at-startup design.

**45. What's your average end-to-end latency, and how did you optimize it?**
[Insert your measured number] — optimized via INT8 quantization, whisper.cpp instead of Python Whisper, and pipelining stages across the Pi's 4 cores instead of a blocking sequential loop.

**46. What is model quantization, and what precision are you using?**
It's compressing a trained model to use smaller numeric precision (INT8 instead of 32-bit floats) so it's smaller and faster to run — like compressing a photo — with a small, usually acceptable accuracy trade-off.

**47. How does your model handle a language/accent it wasn't trained on?**
It degrades gracefully rather than silently — low ASR/NER confidence flows into the overall triage confidence score, which can trigger the "AI uncertain" fallback message instead of a false-confident output.

**48. How confident are you the triage accuracy generalizes beyond your training data?**
Honestly, not fully — that's precisely why we don't rely on the AI alone. The MEWS hard-rule layer and confidence-gated fallback exist because we know a hackathon-stage model can't be trusted blindly on India's diverse regional disease burden.

**49. How do you handle skin-tone-dependent SpO2 inaccuracy?**
We flag it as a known limitation of pulse oximetry generally (documented to under-read hypoxemia in darker skin) — it's on our roadmap to validate and calibrate for this bias as part of post-hackathon clinical evaluation, and the MEWS threshold acts as an added safety layer regardless.

**50. What is "drift detection," and how would you know if your AI degrades in the field?**
It's tracking model confidence scores over time and flagging when the rolling average drops (e.g., below 60%), signaling the AI may be seeing data very different from its training distribution — an early warning before accuracy silently declines.

---

## E. Safety, Failsafe & Clinical Risk

**51. What happens if the AI is wrong and says "Green" for a critically ill patient?**
That's exactly what MEWS is for — fixed vital-sign thresholds (e.g., HR <40 or >130, SpO2 <90%) trigger an automatic Red regardless of what the AI outputs, so a dangerous vital can never be silently missed.

**52. Explain your MEWS failsafe — what are the actual threshold values?**
Heart rate below 40 or above 130 bpm, SpO2 below 90%, and temperature above 39°C or below 35°C each trigger an automatic Red — these are based on the standard Modified Early Warning Score, adapted to our sensor set.

**53. Who decided these thresholds — are they medically validated?**
They're drawn from the standard, publicly documented MEWS clinical scoring framework, adapted to the specific sensors this device has; full clinical validation against real physician diagnoses is scoped as post-hackathon work.

**54. What does the health worker see when confidence is low?**
An explicit "AI uncertain — clinical judgement required" message instead of a Green/Yellow/Red guess — we never let the system default silently to a color when it isn't sure.

**55. Can MEWS ever be silently bypassed by a bug?**
It's designed to be called synchronously by the app before any triage color is rendered — never as an optional secondary screen — and we specifically test it with extreme fake vitals (e.g., HR of 20) to confirm the override can't be skipped.

**56. What's your target false-negative rate, and is that acceptable?**
We haven't hit a validated clinical number yet — that's honestly future work — but our design philosophy is that MEWS's hard rules exist precisely because we don't trust the AI's false-negative rate alone at this stage.

**57. If a patient reports symptoms verbally but sensors show normal vitals, how does the system decide?**
XGBoost combines both symptom text and sensor results into one triage decision — a concerning verbal symptom can still push the color up even with normal vitals; MEWS then acts as the vital-sign-only backstop on top.

**58. How do you avoid alarm fatigue from too many false Reds?**
By calibrating MEWS thresholds carefully against realistic vital-sign ranges, and by giving a clear confidence-based "uncertain" state rather than defaulting to alarm every time — this is an area we'd tune further with real field data.

**59. What clinical validation have you done or plan to do?**
For the hackathon we've written a clinical evaluation protocol outline — comparing device triage against real doctor diagnoses on a sample patient set — as a documented roadmap, not yet executed.

**60. Who takes legal/clinical responsibility for a wrong triage?**
At this stage the device is explicitly positioned as a decision-support and first-line triage aid, not a diagnostic replacement for a doctor — that framing, plus the mandatory clinical-judgement fallback, is core to our regulatory and liability approach.

---

## F. App / UI / UX

**61. Why Flutter instead of native Android?**
Single codebase, fast iteration for a hackathon timeline, and mature packages for offline storage (`sqflite`/Hive), TFLite inference, and connectivity detection — all of which we needed.

**62. How does the app work with zero connectivity?**
All patient data, sensor readings, and AI results are written to a local SQLite/Hive database first; a "synced yes/no" flag marks records for later upload once connectivity returns — the app never depends on being online to function.

**63. How do you resolve sync conflicts?**
We use a simple, explicitly documented rule: the version created most recently on the device wins — chosen because true concurrent edits are unlikely in this workflow, but the rule is written down so behavior is predictable.

**64. How did you design the UI for low digital literacy?**
Big buttons, high-contrast colors, simple icons paired with every text label, and voice-guided prompts — we tested paper sketches and a clickable prototype with people outside the team to see if they could guess what each button did.

**65. How is the app usable in bright outdoor sunlight?**
High-contrast color schemes (dark text on light background or vice versa), avoiding low-contrast pastel combinations that wash out in direct sun.

**66. What testing did you do with a non-technical user?**
We handed the app to someone unfamiliar with the project and watched them complete a full patient check without explanation, noting every point of confusion to fix before the demo.

**67. How does the voice-guided workflow work for different language speakers?**
Pre-recorded prompts or text-to-speech guide each step aloud; for the hackathon it's scoped to one language, but the code is structured so more languages are just additional audio/text assets.

**68. What data does the app store locally, and is it encrypted?**
Patient info, sensor readings, AI results, and sync status are stored locally; [confirm your actual encryption-at-rest implementation] — encryption at rest and TLS 1.3 in transit are part of our security scope owned by the QA/compliance role.

**69. How does patient registration and biometric auth work?**
The app captures basic patient registration details locally, with biometric auth as an access-control layer for the device itself — full biometric patient identity matching is a scoped future enhancement.

**70. What happens if the phone/tablet is lost?**
Local data would be at risk without device-level encryption and lock-screen protection — this is why we scope encryption-at-rest and secure local storage as mandatory, not optional, before any real deployment.

---

## G. Cloud, Backend & Interoperability

**71. Why FastAPI/Node and PostgreSQL + TimescaleDB?**
FastAPI/Node give us fast REST + WebSocket APIs; PostgreSQL handles structured patient profiles well, while TimescaleDB is purpose-built for the time-series vitals data we're constantly ingesting.

**72. What is FHIR, and why does your backend need to comply?**
FHIR (Fast Healthcare Interoperability Resources) is the international standard for structuring health data so different systems can exchange it. We map our data to FHIR R4 resources (Patient, Observation, DiagnosticReport) so our records can eventually interoperate with India's national health stack.

**73. What is ABDM/ABHA, and is your integration real or sandboxed?**
ABDM is India's national digital health mission; ABHA is the patient's health ID. For the hackathon, we scope this as a sandboxed/mocked integration — real ABDM empanelment (HIP/HIU registration) is a non-trivial post-hackathon regulatory workstream, and we say that explicitly rather than overclaiming.

**74. How do you handle teleconsultation over poor 2G/patchy 4G?**
WebRTC is designed for low-bandwidth from day one, with an automatic low-bitrate audio-only fallback when bandwidth drops below a threshold, instead of failing the whole call.

**75. What's your data compression strategy for syncing?**
Protobuf or MessagePack instead of raw JSON/CSV, plus delta-sync — only transmitting new or changed records since the last successful sync, tracked via a local sync cursor.

**76. How does the dashboard detect a potential outbreak?**
Aggregated district-level triage and location data is run through clustering algorithms to flag unusual spatial-temporal patterns — a spike in Red-triage cases in one small area in a short window.

**77. Why both Isolation Forest and DBSCAN?**
Isolation Forest is good at flagging outlier locations with surprisingly bad results compared to normal; DBSCAN groups nearby points into clusters, useful for spotting a tight geographic cluster of concerning cases — we use both because they catch different patterns.

**78. How do you secure data at rest and in transit?**
AES-256 encryption for stored data and TLS 1.3 for anything traveling over the network — most managed database/hosting providers support this by default, and we confirm it's enabled rather than assuming.

**79. How do you prevent unauthorized API access to patient records?**
Authentication is required on every endpoint; we specifically test this by trying to call APIs without logging in first and confirming they're correctly refused.

**80. Have you load-tested simultaneous syncs from many devices?**
Not yet at hackathon scale — that's flagged as a scaling concern for real deployment, and our delta-sync + queue-and-batch approach is designed to reduce simultaneous load in the first place.

---

## H. Regulatory, Legal & Compliance

**81. Is this device classified as a medical device under Indian law?**
Under India's Medical Device Rules, a device outputting a diagnostic/triage recommendation almost certainly qualifies as Software as a Medical Device (SaMD), likely Class B or C given its ECG/triage-influencing functions.

**82. What is CDSCO, and what's your compliance roadmap?**
CDSCO is India's medical device regulator. For the hackathon we've written a documented classification rationale and roadmap of what real CDSCO review would require — not an actual completed audit, which we're upfront about with judges.

**83. How do you obtain informed consent from a low-literacy patient under DPDP Act?**
A short voice message in the patient's own language explaining what data is collected and why, followed by a simple yes/no confirmation the health worker helps them give — designed as both a UX and legal requirement, before any sensor data is collected.

**84. What happens if a patient refuses consent?**
No sensor data or personal health information is collected or stored for that encounter — consent capture is designed to happen first, gating everything downstream.

**85. Who owns the patient's health data?**
The patient, per DPDP Act principles — our system is designed to be a custodian/processor of that data under explicit consent, not an owner.

**86. What's your data retention and deletion policy?**
[State your actual policy] — this is part of the compliance documentation the QA/compliance role owns; at minimum it should align with DPDP Act requirements for purpose limitation and deletion on request.

**87. Are you liable if a health worker uses the device outside its intended scope?**
The device is scoped and documented as a triage decision-support tool for trained ASHA/ANM use, not general-purpose diagnostics — intended use and training materials are part of our deployment plan to keep usage within scope.

**88. What real-world regulatory approval would this need before deployment?**
Full CDSCO SaMD licensing with clinical evaluation from an accredited testing lab, formal ABDM HIP/HIU empanelment, and DPDP-compliant consent infrastructure audited end-to-end — all explicitly scoped as post-hackathon work in our roadmap.

---

## I. Feasibility, Business & Scaling

**89. What is your per-unit production cost at scale?**
[Insert your real BOM-based estimate] — component costs drop meaningfully at volume (1,000+ units) due to bulk sourcing of ESP32/Pi boards and sensors; state your actual projected number here.

**90. What's your go-to-market or deployment plan?**
Most realistic path is government/NGO partnership (e.g., National Health Mission, state PHC networks) rather than direct-to-consumer, given the target users are ASHA/ANM government health workers.

**91. How do you plan to fund manufacturing and distribution?**
[Insert your actual plan — grants, government procurement, CSR partnerships, etc.]

**92. What's your maintenance/repair plan for remote-area devices?**
Modular hardware design so faulty sensors can be swapped in the field, plus a spare/backup unit strategy for demo and eventually for field deployment redundancy.

**93. How do you train ASHAs/ANMs to use this device?**
The voice-guided, icon-based UI is designed to minimize training need; a short in-person onboarding session plus the in-app guided workflow is the intended rollout approach.

**94. What's your competitive landscape?**
Existing solutions are largely fragmented single-purpose Bluetooth peripherals (separate pulse-ox, separate BP monitor) requiring constant connectivity and doctor interpretation — our differentiation is unified offline Edge-AI triage in one device.

**95. How do you keep AI models updated in the field without full internet?**
Opportunistic model updates when Wi-Fi is detected (similar to our delta-sync approach for patient records), rather than requiring constant connectivity.

**96. What's your 3-5 year vision beyond the hackathon?**
Multi-language support, clinically validated triage accuracy through real-world pilots, full CDSCO/ABDM compliance, and integration into state-level PHC digital health infrastructure at scale.

---

## J. Team & Execution

**97. How did you divide the 5 roles, and why that split?**
Edge AI, Full-Stack/Cloud, Firmware, App/UI, and Systems Integration/QA-Compliance — mapped to each layer of the technical stack so every component has a clear owner and interface contract with the others.

**98. What's the single biggest technical risk your team is most worried about?**
Getting all five AI models to run within the Pi 4's RAM and latency budget in real time — it's why quantization and lazy-loading were prioritized early rather than left for later.

**99. What have you actually built so far vs. what's still on the roadmap?**
[State your real current status honestly] — e.g., "Sensors are wired and calibrated, filter pipelines are built; AI models are in training/quantization; app offline-sync and MEWS integration are in progress." Be precise and honest here — judges value accurate scoping over overclaiming.

**100. If you had 2 more weeks, what would you prioritize?**
Full-pipeline hardware-in-the-loop testing with real sensor data end-to-end, plus refining triage model accuracy against edge-case test scenarios.

**101. What did you learn building this that you didn't know before?**
[Answer genuinely, team-specific] — common honest answers: how much of "AI in healthcare" is really about failure-mode engineering (MEWS) rather than just model accuracy, or how much regulatory/compliance scoping matters even at hackathon stage.

**102. How does each role's work depend on another — what's your critical path?**
Firmware → AI → App → Web/Cloud → QA is our critical path; the single riskiest dependency is QA's MEWS fallback module getting integrated into the App's UI before end-to-end testing — we treat that as the most safety-critical handoff in the whole project.

---

## Notes on Bracketed Answers

A few answers above are marked `[Insert your actual number/plan]` — these are placeholders for data only your team has (measured accuracy, real BOM cost, funding plan, current build status). Fill these in honestly before your presentation; a specific real number always beats a vague one, and judges can tell the difference.
