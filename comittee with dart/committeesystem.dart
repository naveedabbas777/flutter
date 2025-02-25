import 'dart:io';
import 'dart:math';
import 'dart:convert';

class Member {
  String name;
  double contribution;

  Member(this.name, this.contribution);

  Map<String, dynamic> toJson() => {'name': name, 'contribution': contribution};

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(json['name'], json['contribution']);
  }
}

class Committee {
  List<Member> members = [];
  double totalContribution = 0;
  final Random random = Random();
  final String filePath = 'committee_data.json';

  Committee() {
    loadCommittee();
  }

  void addMember(String name, double contribution) {
    if (contribution <= 0) {
      print('\x1B[31m❌ Contribution must be greater than zero.\x1B[0m');
      return;
    }
    members.add(Member(name, contribution));
    totalContribution += contribution;
    saveCommittee();
    print('\x1B[32m✅ Member added successfully!\x1B[0m');
  }

  void displayMembers() {
    if (members.isEmpty) {
      print('\x1B[33m⚠️ No members in the committee.\x1B[0m');
      return;
    }
    print('\n\x1B[34m📜 Committee Members:\x1B[0m');
    for (var i = 0; i < members.length; i++) {
      print(
        '${i + 1}. ${members[i].name} - Contribution: \$${members[i].contribution.toStringAsFixed(2)}',
      );
    }
    print(
      '💰 \x1B[35mTotal Contribution: \$${totalContribution.toStringAsFixed(2)}\x1B[0m',
    );
  }

  void luckyDraw() {
    if (members.isEmpty) {
      print('\x1B[33m⚠️ No members left for the lucky draw.\x1B[0m');
      return;
    }

    int winnerIndex = random.nextInt(members.length);
    Member winner = members[winnerIndex];

    print('\n\x1B[32m🎉 Lucky Draw Winner: ${winner.name} 🎉\x1B[0m');
    print(
      '🏆 \x1B[36mThey receive the total contribution of \$${totalContribution.toStringAsFixed(2)}!\x1B[0m',
    );

    members.removeAt(winnerIndex);
    totalContribution = members.fold(
      0,
      (sum, member) => sum + member.contribution,
    );

    saveCommittee();

    if (members.isEmpty) {
      print(
        '\x1B[32m✅ All members have won. The committee is now empty.\x1B[0m',
      );
    }
  }

  void saveCommittee() {
    try {
      File file = File(filePath);
      file.writeAsStringSync(
        jsonEncode(members.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      print('\x1B[31m❌ Error saving data: $e\x1B[0m');
    }
  }

  void loadCommittee() {
    try {
      File file = File(filePath);
      if (file.existsSync()) {
        List<dynamic> data = jsonDecode(file.readAsStringSync());
        members = data.map((json) => Member.fromJson(json)).toList();
        totalContribution = members.fold(
          0,
          (sum, member) => sum + member.contribution,
        );
      } else {
        print('\x1B[33m⚠️ No previous data found. Starting fresh.\x1B[0m');
      }
    } catch (e) {
      print('\x1B[31m❌ Error loading data: $e\x1B[0m');
    }
  }
}

void main() {
  Committee committee = Committee();

  while (true) {
    print('\n🔹 \x1B[36mCommittee Management System\x1B[0m 🔹');
    print('1️⃣ Add Member');
    print('2️⃣ View Members');
    print('3️⃣ Conduct Lucky Draw');
    print('4️⃣ Exit');
    stdout.write('Enter your choice: ');
    String? choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        stdout.write('Enter member name: ');
        String? name = stdin.readLineSync()?.trim();
        stdout.write('Enter contribution amount: ');
        double? contribution = double.tryParse(stdin.readLineSync() ?? '');
        if (name != null && name.isNotEmpty && contribution != null) {
          committee.addMember(name, contribution);
        } else {
          print('\x1B[31m❌ Invalid input. Try again.\x1B[0m');
        }
        break;
      case '2':
        committee.displayMembers();
        break;
      case '3':
        committee.luckyDraw();
        break;
      case '4':
        print('\x1B[32m🚪 Exiting... Thank you!\x1B[0m');
        return;
      default:
        print('\x1B[31m❌ Invalid choice. Try again.\x1B[0m');
    }
  }
}
