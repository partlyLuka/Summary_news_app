import argparse
from datasets import load_dataset
import ctranslate2
import sentencepiece as spm
import time
from torch.utils.data import DataLoader

# Global variable to keep track of the progress
translated_percentage = 0.0
total_data_size = 0

def load_models(ct_model_path, sp_model_path, device, device_index):
    sp = spm.SentencePieceProcessor()
    sp.load(sp_model_path)
    translator = ctranslate2.Translator(ct_model_path, device=device, device_index=device_index)
    return sp, translator

def load_data():
    global total_data_size
    dataset = load_dataset('imdb')
    total_data_size = len(dataset['train'])
    dataloader = DataLoader(dataset['train'], batch_size=8192, num_workers=64)
    return dataloader

def translate(translator, sentences, sp, src_lang, tgt_lang, beam_size):
    global translated_percentage

    source_sentences = [sent.strip() for sent in sentences]
    
    target_prefix = [[tgt_lang]] * len(source_sentences)
    source_sents_subworded = sp.encode_as_pieces(source_sentences)
    source_sents_subworded = [[src_lang] + sent + ["</s>"] for sent in source_sents_subworded]
    #print(source_sents_subworded)
    start_time = time.time()
    
    translations_subworded = translator.translate_batch(source_sents_subworded, end_token="</s>",max_batch_size=320, beam_size=beam_size, target_prefix=target_prefix, return_scores=False)
    #print(translations_subworded)
    translations_subworded = [translation.hypotheses[0] for translation in translations_subworded]
    duration = time.time() - start_time

    translations = [sp.decode(translation) for translation in translations_subworded]

    return translations, duration

def main(ct_model_path, sp_model_path, tgt_lang, beam_size, device, device_index, p, output_file):
    global translated_percentage
    global total_data_size
    src_lang = "eng_Latn"
    target_data_size = total_data_size * (p / 100.0)

    sp, translator = load_models(ct_model_path, sp_model_path, device, device_index)
    dataloader = load_data()

    for batch in dataloader:
        for key in ['query', 'positive', 'negative']:
            if translated_percentage >= total_data_size:
                print(f"Reached the target of translating {p}% of the data. {translated_percentage}, {total_data_size}")
                return
            print(f"Translating {key} sentences...")
            sentences = batch[key]
            translations, duration = translate(translator, sentences, sp, src_lang, tgt_lang, beam_size)
            with open(f"data/{ct_model_path}_{tgt_lang}_{p}_{key}.txt", "a", encoding="utf-8") as f:
                for line in translations:
                    f.write(line + "\n")
            if key == 'query':     translated_percentage += len(sentences)
            print(f"Translated {len(sentences)} {key} sentences in {duration} seconds.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Translate sentences from a dataset using a machine translation model.')
    parser.add_argument('--tgt_lang', type=str, default ='slv_Latn', required=True, help='Target language code.')
    parser.add_argument('--ct_model_path', type=str, required=True, help='Path to the ctranslate2 model.')
    parser.add_argument('--beam_size', type=int, default=1, help='Beam size for the translation.')
    parser.add_argument('--device', type=str, default="cuda", help='Device to use for translation (cuda:0 or cpu).')
    parser.add_argument('--device_index', nargs='*', type=list, default=[0], help='Device indices for translation.')
    parser.add_argument('--p', type=float, default=100, help='Percentage of the data to use.')
    parser.add_argument('--output_file', type=str, default="translations", help='Base name for the output files where the translations will be saved.')

    args = parser.parse_args()
    print("Running with following args: ", args)
    main(args.ct_model_path, "flores200_sacrebleu_tokenizer_spm.model", args.tgt_lang, args.beam_size, args.device, args.device_index, args.p, args.output_file)