# Omnichannel Marketing Multi-Touch Attribution Engine

An algorithmic marketing attribution framework comparing traditional heuristic models (First-Touch, Last-Touch) against First-Order Markov Chain transition models across multi-channel customer journeys.

## Overview
Relying solely on last-touch conversion data systematically undervalues upper-funnel discovery channels (e.g. Paid Social, YouTube) and artificially inflates brand search attribution. This project parses multi-step clickstream paths to model transition probabilities, quantify channel removal effects, and balance advertising budget allocation.

## Project Structure
- `customer_journey_touchpoints.sql`: SQL query tracking cross-channel session sequences and generating aggregated conversion paths.
- `markov_attribution_engine.py`: Python script simulating 20k+ user journeys and computing removal-effect Markov Chain weights.
- `requirements.txt`: Python package dependencies.

## Key Logic & Metrics
1. **Journey Path Reconstruction:** Aggregating granular click events into ordered customer sequences (`STRING_AGG(channel, ' > ')`).
2. **Transition Probability Graph:** Mapping touchpoint sequences to state transition matrices (`Start -> [Channels] -> Conversion / Drop-off`).
3. **Removal Effect Index:** Measuring the delta in conversion probability when an individual channel is systematically eliminated from traversal paths.
4. **Budget Reallocation Delta:** Quantifying credit shift between Last-Touch and Algorithmic Markov models to prevent marketing budget cannibalization.

## How to Run

```bash
# Clone the repository
git clone [https://github.com/puneetgoswami1/omnichannel-marketing-attribution-engine.git](https://github.com/puneetgoswami1/omnichannel-marketing-attribution-engine.git)
cd omnichannel-marketing-attribution-engine

# Install dependencies
pip install -r requirements.txt

# Run attribution model
python markov_attribution_engine.py