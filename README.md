# py-hLEPOR

``py-hLEPOR`` is a Python Bindings to [hLEPOR](https://github.com/aaronlifenghan/aaron-project-hlepor) metric

## Syntax

``py-hLEPOR`` supports both file and sentence level. In case of sentence-level uses "\n" as a line separator.

```python
python py-hLEPOR.py "reference_file|reference_sentences" "candidate_file|candidate_sentences"
```

# Usage
  Input example:
  
```python
python hlepor/py-hLEPOR.py "Ánimo hola\nterminar la máquina" "Vamos hola\nponer fin a la máquina" > output.json
```

  Output example (Pretty-print):
```json
{
   "id":433,
   "reference_sentence":[
      "Ánimo hola",
      "terminar la máquina"
   ],
   "candidate_sentence":[
      "Vamos hola",
      "poner fin a la máquina"
   ],
   "length_of_sysoutput":[
      "2",
      "5"
   ],
   "length_of_reference":[
      "2",
      "3"
   ],
   "length_penalty_with_longer_or_shorter":[
      "1",
      "0.513417119032592"
   ],
   "mean_of_length_penalty_with_longer_or_shorter":[
      "0.756708559516296"
   ],
   "common_number_between_sys_and_ref":[
      "1",
      "2"
   ],
   "precision_of_sys":[
      "0.5",
      "0.4"
   ],
   "recall_of_sys":[
      "0.5",
      "0.666666666666667"
   ],
   "mean_precision_of_sys":[
      "0.45"
   ],
   "mean_recall_of_sys":[
      "0.583333333333333"
   ],
   "harmonic_of_precision_and_recall":[
      "0.5",
      "0.625"
   ],
   "mean_of_every_sentences_harmonic-mean_of_precision_and_recall":[
      "0.5625"
   ],
   "position_different_penalty":[
      "1",
      "0.973685749353145"
   ],
   "mean_position_different_penalty":[
      "0.986842874676573"
   ],
   "evaluation_value_hlepor_of_every_single_sentence":[
      "0.588235294117647",
      "0.620251452337594"
   ],
   "mean_value_hlepor_of_all_single_sentence":[
      "0.60424337322762"
   ],
   "mean_value_hlepor_anotherway_of_all_single_sentence":[
      "0.621087055947722"
   ]
}
```
