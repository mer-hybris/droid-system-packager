/*
 * Contact: Carsten Munk <carsten.munk@jollamobile.com>
 *
 * Copyright (c) 2013, Jolla Ltd.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * * Neither the name of the <organization> nor the
 * names of its contributors may be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "private/android_filesystem_config.h"
#include <assert.h>

int main(int argc, char *argv[])
{
	int dir = (*argv[2] == 'd');
	unsigned uid = 0, gid = 0, mode = 0;
	char *tuid, *tgid;
	int i;

	fs_config(argv[1], dir, &uid, &gid, &mode);

	tuid = NULL;
	for (i = 0; i < android_id_count; i++)
		if (uid == android_ids[i].aid)
			tuid = android_ids[i].name;

	assert(tuid != NULL);

	tgid = NULL;
	for (i = 0; i < android_id_count; i++)
		if (gid == android_ids[i].aid)
			tgid = android_ids[i].name;

	assert(tgid != NULL);
	
	
	if (!dir)
		printf("%%attr(%o, %s, %s) /%s\n", mode, tuid, tgid, argv[1]);
	else
		printf("%%attr(%o, %s, %s) %%dir /%s\n", mode, tuid, tgid, argv[1]); 
	
	return 0;
}
