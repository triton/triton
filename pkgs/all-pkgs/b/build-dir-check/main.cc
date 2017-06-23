#include <iostream>
#include <string>
#include <string_view>
#include <vector>

namespace {

using ::std::cout;
using ::std::endl;
using ::std::string;
using ::std::vector;

constexpr size_t kBufSize = 64 * 1024;

}  // namespace

int main(int argc, char *argv[]) {
    if (argc < 2) {
        cout << "Usage: " << argv[0] << " <dir-to-check>" << endl;
        return 2;
    }
    const string_view dir_to_check(argv[1]);

    cout << "Checking for build directory impurity:" << endl;
    return 0;
}
