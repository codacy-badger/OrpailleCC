EXE=main
TEST_DIR=./tests
SRC_DIR=./src
OBJECT=
CPPOBJECT=$(TEST_DIR)/test_bloom.oo\
		  $(TEST_DIR)/test_cuckoo.oo\
		  $(TEST_DIR)/test_reservoir_sampling.oo\
		  $(TEST_DIR)/test_chained_reservoir.oo\
		  $(TEST_DIR)/test_ltc.oo\
		  $(TEST_DIR)/test_mc_nn.oo 

FLAG_GCOV=-fprofile-arcs -ftest-coverage

ifeq ($(config), debug)
CFLAGS=-DDEBUG -g -O0 $(FLAG_GCOV)
else #release config by default
CFLAGS=-Os -O3
endif

all: $(OBJECT) main.cpp
	g++ -I$(SRC_DIR) -std=c++11 main.cpp $(OBJECT) $(CFLAGS) -o $(EXE)

test: $(CPPOBJECT) $(TEST_DIR)/test.cpp
	g++ -I$(SRC_DIR) -std=c++11 -fpermissive $(TEST_DIR)/test.cpp $(CPPOBJECT) $(CFLAGS) -o $(EXE)-test -lgtest -lpthread -lgcov

perf: $(OBJECT)
	g++ -I$(SRC_DIR) -std=c++11 main-performance.cpp $(OBJECT) $(CFLAGS) -o $(EXE)-perf

run_test: test
	./$(EXE)-test

coverage: run_test
	mkdir coverage
	gcov test
	lcov -c --directory . --output-file coverage.info --no-external
	genhtml coverage.info --output-directory coverage

%.o: %.c
	gcc -std=c99 $< -c -o $@

%.oo: %.cpp
	g++ -I$(SRC_DIR) -std=c++11 $(CFLAGS) $< -c -o $@ -fpermissive

clean:
	rm -f *.o *.oo $(TEST_DIR)/*.oo $(SRC_DIR)/*.oo $(EXE) $(EXE)-test $(EXE)-perf
	rm -rf coverage 
	rm -f test.gcda test.gcno $(TEST_DIR)/*.gcda $(TEST_DIR)/*.gcno coverage.info
