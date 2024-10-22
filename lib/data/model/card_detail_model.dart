class CardDetails {
  String? name;
  String? phone;
  String? email;
  String? address;
  String? designation;
  String? company;

  CardDetails({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.designation,
    this.company,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'designation': designation,
    'company': company,
  };

  factory CardDetails.fromJson(Map<String, dynamic> json) => CardDetails(
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    address: json['address'],
    designation: json['designation'],
    company: json['company'],
  );
}
