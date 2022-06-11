.PHONY: build

build:
	python3 setup.py build_ext --inplace

install:
	python3 setup.py install

talib/_func.pxi: tools/generate_func.py
	python3 tools/generate_func.py > talib/_func.pxi

talib/_stream.pxi: tools/generate_stream.py
	python3 tools/generate_stream.py > talib/_stream.pxi

generate: talib/_func.pxi talib/_stream.pxi

cython:
	cython --directive emit_code_comments=False talib/_ta_lib.pyx

clean:
	rm -rf build talib/_ta_lib.so talib/*.pyc

perf:
	python3 tools/perf_talib.py

download:
	curl -L -O http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz

run-docker:
	docker run -it -v $(pwd):/io quay.io/pypa/manylinux2014_x86_64

install-ta-lib:
	tar -xzf ta-lib-0.4.0-src.tar.gz 
	cd ta-lib/ && ./configure && make && make install && cd ..

manylinux-wheel:
	for PYBIN in $(wildcard /opt/python/*/bin);	\
	do	\
		$$PYBIN/pip install -r requirements.txt;	\
		$$PYBIN/pip wheel ./ -w wheelhouse/;	\
		rm -rf build;	\
	done

repair-manylinux-wheel:
	for whl in $(wildcard wheelhouse/ta_lib_bin*.whl);	\
	do	\
		auditwheel repair $$whl -w wheelhouse/;	\
	done

install-test:
	rm -rf ta-lib
	for PYBIN in $(wildcard /opt/python/*/bin);	\
	do	\
		$$PYBIN/pip install ta-lib-bin --no-index -f wheelhouse;	\
	done