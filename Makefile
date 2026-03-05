FSTAR	  = fstar.exe
OUT       = out
CACHE_DIR = $(OUT)/checked_cache
BUILD_DIR = $(OUT)/build
ENTRY     = Main

FSTAR_ARGS  = --cache_dir $(CACHE_DIR)
FSTAR_ARGS += --already_cached Prims,FStar,LowStar
FSTAR_ARGS += --warn_error -321

FSTAR_FILES = $(wildcard *.fst) $(wildcard *.fsti)

all: verify

$(OUT)/.depend: $(FSTAR_FILES)
	mkdir -p $(OUT)
	$(FSTAR) $(FSTAR_ARGS) --dep full $(FSTAR_FILES) -o $@

-include $(OUT)/.depend

$(CACHE_DIR)/%.fst.checked:
	mkdir -p $(CACHE_DIR)
	$(FSTAR) $(FSTAR_ARGS) -c $< -o $@

$(CACHE_DIR)/%.fsti.checked:
	mkdir -p $(CACHE_DIR)
	$(FSTAR) $(FSTAR_ARGS) -c $< -o $@

verify: $(ALL_CHECKED_FILES)

$(BUILD_DIR)/$(ENTRY)/$(ENTRY).native: $(ALL_CHECKED_FILES)
	mkdir -p $(BUILD_DIR)/$(ENTRY)
	$(FSTAR) $(FSTAR_ARGS) --codegen OCaml --extract '$(ENTRY) -Prims -FStar' --odir $(BUILD_DIR)/$(ENTRY) $(ENTRY).fst
	cd $(BUILD_DIR)/$(ENTRY) && ocamlfind ocamlopt -package fstar.lib -linkpkg $$(ocamldep -sort *.ml) -o $(ENTRY).native

run: $(BUILD_DIR)/$(ENTRY)/$(ENTRY).native
	@$<

clean:
	rm -rf $(OUT)

.PHONY: all verify run clean
