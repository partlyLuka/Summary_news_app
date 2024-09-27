from translation import load_models, translate
import stanza
import logging
import pandas as pd
import os
import sys
import argparse

logging.getLogger('stanza').disabled = True
nlp = stanza.Pipeline("sl", processors="tokenize")

def get_sentences(document):
    try:
        # Redirect stdout to a null file
        
        # Load the Slovenian model
        
        # Process the document and extract sentences
        doc = nlp(document)
        sentences = [sentence.text for sentence in doc.sentences]
        
        return sentences
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
    

def translate_document(document,
                        translator,
                        sp,
                        beam_size=1,
                        
                        src_lang="slv_Latn",
                        tgt_lang='eng_Latn'
                        ):
    
    
    
    sentences = get_sentences(document)
    
    
    translated_sentences, _ = translate(translator=translator, sentences=sentences, sp=sp, beam_size=1, src_lang=src_lang,tgt_lang=tgt_lang)
    translated_sentences = [strg.replace("eng_Latn ", "") for strg in translated_sentences]
    
    return " ".join(translated_sentences)

ct_model_path = "backend/rtv/translation/trans_models_small/nllb-200-distilled-600M-int8"
sp_model_path = "backend/rtv/translation/trans_models_small/flores200_sacrebleu_tokenizer_spm.model"
sp, translator = load_models(ct_model_path=ct_model_path, sp_model_path=sp_model_path, device="cpu", device_index=0)

def english(slovene):
    text = []
    for p in slovene.split("\n\n"):
        tr = translate_document(p,
                        translator=translator,
                        sp=sp,
                        beam_size=1,
                        
                        src_lang="slv_Latn",
                        tgt_lang='eng_Latn'
                        )
        text.append(tr)
    return "\n\n".join(text)
