#include "incApache.h"

void fail(const char *const msg)
{
	fprintf(stderr, "%s\n", msg);
	exit(EXIT_FAILURE);
}

void fail_errno(const char *const msg)
{
	perror(msg);
	exit(EXIT_FAILURE);
}

void *my_malloc(size_t size)
{
	void *result = malloc(size);
	if (!result)
		fail_errno("Cannot allocate memory with malloc");
	return result;
}

char *my_strdup(const char *const s)
{
	char *result = strdup(s);
	if (!result)
		fail_errno("Cannot allocate memory for strdup");
	return result;
}