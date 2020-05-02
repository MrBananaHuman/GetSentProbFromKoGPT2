import torch
import torch.nn.functional as F
from kogpt2.pytorch_kogpt2 import get_pytorch_kogpt2_model
from gluonnlp.data import SentencepieceTokenizer
from kogpt2.utils import get_tokenizer

tok_path = get_tokenizer()
model, vocab = get_pytorch_kogpt2_model()
tok = SentencepieceTokenizer(tok_path)
ori_sent = '안녕하세요. 저는 김성현입니다. 만나서 진심으로 반갑습니다.'
toked = tok(ori_sent)

print('toked:', toked)
print('toked_id:', vocab[toked])

for i in range(1,len(toked)):
    current_sent = toked[0:i]
    next_token_id = vocab[toked[i]]
    input_ids = torch.tensor([vocab[vocab.bos_token],]  + vocab[current_sent]).unsqueeze(0)
    pred = model(input_ids)[0][-1][-1]
    probs = F.softmax(pred, dim=-1)
    print(current_sent)
    print('next_token_prob:', vocab.to_tokens(next_token_id), '\t', probs.tolist()[next_token_id])
    best_token_id = torch.argmax(probs)
    print('best_next_token_prob:', vocab.to_tokens(best_token_id.tolist()), '\t', probs.tolist()[best_token_id], '\n')    

