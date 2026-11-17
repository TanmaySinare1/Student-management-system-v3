CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -Wpedantic -g -O0
LDLIBS = -lsqlite3 -lcrypto
APP = student_management
CORE_SOURCES = database.cpp auth.cpp student.cpp attendance.cpp fees.cpp reports.cpp admin.cpp
SOURCES = main.cpp $(CORE_SOURCES)
GTEST_CFLAGS := $(shell pkg-config --cflags gtest 2>/dev/null)
GTEST_LIBS := $(shell pkg-config --libs gtest 2>/dev/null)
TEST_BIN = tests/project_tests
TEST_SOURCES = tests/project_tests.cpp $(SOURCES)

.PHONY: all run clean test coverage valgrind cppcheck tools
all: $(APP)
$(APP): $(SOURCES)
	$(CXX) $(CXXFLAGS) $(SOURCES) $(LDLIBS) -o $@
run: $(APP)
	./$(APP)
$(TEST_BIN): $(TEST_SOURCES)
	$(CXX) $(CXXFLAGS) $(GTEST_CFLAGS) -I. -Dmain=studentManagementProgramMain tests/project_tests.cpp $(SOURCES) $(LDLIBS) $(GTEST_LIBS) -lgtest_main -pthread -o $@
test: $(TEST_BIN)
	./$(TEST_BIN)
coverage:
	$(CXX) $(CXXFLAGS) --coverage $(GTEST_CFLAGS) -I. -Dmain=studentManagementProgramMain tests/project_tests.cpp $(SOURCES) $(LDLIBS) $(GTEST_LIBS) -lgtest_main -pthread --coverage -o tests/project_tests_coverage
	./tests/project_tests_coverage
	gcov -b -c $(SOURCES)
valgrind: $(APP)
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --error-exitcode=1 ./$(APP)
cppcheck:
	cppcheck --enable=warning,performance,portability --inconclusive --std=c++17 --suppress=missingIncludeSystem $(SOURCES) tests/project_tests.cpp
tools:
	@command -v g++ >/dev/null || (echo "g++ missing"; exit 1)
	@command -v valgrind >/dev/null || echo "Valgrind missing"
	@command -v cppcheck >/dev/null || echo "Cppcheck missing"
	@pkg-config --exists gtest || echo "GoogleTest pkg-config missing"
clean:
	rm -f $(APP) $(TEST_BIN) tests/project_tests_coverage *.gcda *.gcno *.gcov
