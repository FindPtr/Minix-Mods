all: forktest pipetest infromfile outtofile exectest multipipetest nohuptest


forktest:
	gcc forktest.c -o fork_test
	./fork_test

pipetest:
	gcc pipetest.c -o pipe_test
	./pipe_test

infromfile:
	gcc infromfile.c -o in_from_file
	./in_from_file

exectest:
	gcc exectest.c -o exec_test
	./exec_test

outtofile:
	gcc outtofile.c -o out_to_file
	./out_to_file
	cat example_out.txt

multipipetest:
	gcc multipipetest.c -o multi_pipe_test
	./multi_pipe_test
	
nohuptest:
	gcc nohuptest.c -o no_hup_test
	./no_hup_test

clean:
	rm *_*