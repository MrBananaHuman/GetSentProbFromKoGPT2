class WordNode{
  String label;
  int tokenId;
  int rank;
  float score;
  int selected;
  
  WordNode(String label, int tokenId, int rank, float score, int selected){
    this.label = label;
    this.tokenId = tokenId;
    this.rank = rank;
    this.score = score;
    this.selected = selected;
    //if(rank == 0){
    //  this.selected = 1;
    //} else{
    //  this.selected = 0;
    //}
  }
}
