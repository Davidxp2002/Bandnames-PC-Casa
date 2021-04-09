class Band {
  String id;
  String name;
  int votes;
  Band({this.id, this.name, this.votes});

  factory Band.fromMap(Map<String, dynamic> obj) => Band(
      id: obj.containsKey('id') ? obj['id'] : 'no hay id',
      name: obj.containsKey('name') ? obj['name'] : 'no hay nombre',
      votes: obj.containsKey('votes')
          ? obj['votes']
          : 'no se recuperaron los votos');
}
