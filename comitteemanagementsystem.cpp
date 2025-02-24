#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

using namespace std;

struct Member {
    string name;
    double contribution;
};

class Committee {
private:
    vector<Member> members;
    double totalContribution;

public:
    Committee() : totalContribution(0) {}

    // Add member
    void addMember(const string& name, double contribution) {
        members.push_back({name, contribution});
        totalContribution += contribution;
    }

    // Display all members
    void displayMembers() {
        if (members.empty()) {
            cout << "No members in the committee.\n";
            return;
        }
        cout << "Committee Members:\n";
        for (size_t i = 0; i < members.size(); ++i) {
            cout << i + 1 << ". " << members[i].name << " - Contribution: $" << members[i].contribution << "\n";
        }
        cout << "Total Contribution: $" << totalContribution << "\n";
    }

    // Conduct lucky draw
    void luckyDraw() {
        if (members.empty()) {
            cout << "No members left for the lucky draw.\n";
            return;
        }

        srand(time(0));
        int winnerIndex = rand() % members.size();
        
        cout << "\n🎉 Lucky Draw Winner: " << members[winnerIndex].name << " 🎉\n";
        cout << "They receive the total contribution of $" << totalContribution << "!\n";

        // Remove the winner and reset the contributions
        members.erase(members.begin() + winnerIndex);
        totalContribution = 0;

        // Recalculate total contribution
        for (const auto& member : members) {
            totalContribution += member.contribution;
        }

        if (members.empty()) {
            cout << "All members have won. Committee is empty now.\n";
        }
    }
};

int main() {
    Committee committee;
    int choice;

    while (true) {
        cout << "\nCommittee Management System\n";
        cout << "1. Add Member\n";
        cout << "2. View Members\n";
        cout << "3. Conduct Lucky Draw\n";
        cout << "4. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        if (choice == 1) {
            string name;
            double contribution;
            cout << "Enter member name: ";
            cin >> name;
            cout << "Enter contribution amount: ";
            cin >> contribution;
            committee.addMember(name, contribution);
        } 
        else if (choice == 2) {
            committee.displayMembers();
        } 
        else if (choice == 3) {
            committee.luckyDraw();
        } 
        else if (choice == 4) {
            cout << "Exiting...\n";
            break;
        } 
        else {
            cout << "Invalid choice. Try again.\n";
        }
    }

    return 0;
}
