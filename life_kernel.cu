
// Reads a cell at (x+dx, y+dy)
__device__ int read_cell(int * source_domain, int x, int y, int dx, int dy,
    unsigned int domain_x, unsigned int domain_y)
{
    x = (unsigned int)(x + dx) % domain_x;	// Wrap around
    y = (unsigned int)(y + dy) % domain_y;
    return source_domain[y * domain_x + x];
}

__device__ int read_sharedCell(int * source_domain, int x, int y, int dx, int dy,
    unsigned int domainBlock,
    int * global_domain, int gx, int gy, unsigned int domain_x, unsigned int domain_y)
{
    x = (unsigned int)(x + dx);	// Wrap around
    y = (unsigned int)(y + dy);
    if(x >= domainBlock || y>= domainBlock || x<0 || y<0){
		return read_cell(global_domain, gx, gy, 0, 0,
	                       domain_x, domain_y);
	}
    return source_domain[y * domain_x + x];
}

__device__ void read_neighbors(int * source, int x, int y, int dx, int dy,
    unsigned int domainBlock, int *red, int *blue,
    int * global_domain, int gx, int gy, unsigned int domain_x, unsigned int domain_y)
{
	int cells[8];
	cells[0] =read_sharedCell(source, x, y, 0 , 1 , domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[1] =read_sharedCell(source, x, y, 1 , 1 , domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[2] =read_sharedCell(source, x, y, 1 , 0 , domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[3] =read_sharedCell(source, x, y, 1 , -1, domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[4] =read_sharedCell(source, x, y, 0 , -1, domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[5] =read_sharedCell(source, x, y, -1, -1, domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[6] =read_sharedCell(source, x, y, -1, 0 , domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	cells[7] =read_sharedCell(source, x, y, -1, 1 , domainBlock,
	global_domain,gx,gy,domain_x,domain_y);
	
	for(int i = 0; i<8; i++){
		if(cells[i] == 1){
			(*red)++;
		}
		else if(cells[i] == 2){
			(*blue)++;
		}
	}
}


__device__ void new_value(int * source_domain, int x, int y,
	int myself, int *red, int *blue, int *value)
{
	if(((*red) + (*blue) > 3) || ((*red) + (*blue) < 2)){
		(*value) = 0;
	}else if(myself == 0 && (*red) + (*blue) == 3){
		if((*red) > (*blue)){
			(*value) = 1;
		}else{
			(*value) = 2;
		}
	}else{
		(*value) = myself;
	}
}

// Compute kernel
__global__ void life_kernel(int * source_domain, int * dest_domain,
    int domain_x, int domain_y)
{
	__shared__ int sharedCells[64];
	
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	
    int gx = blockIdx.x * blockDim.x + threadIdx.x;
    int gy = blockIdx.y;
    
    // Read cell
    int myself = read_cell(source_domain, tx, ty, 0, 0,
	                       domain_x, domain_y);
	                       
	int domainBlock = 64;
	                       
	sharedCells[ty]=myself;
	
	__syncthreads();
	
    
    // TODO: Read the 8 neighbors and count number of blue and red
	
	int red = 0;
	int blue = 0;
	
	read_neighbors(sharedCells, tx, ty, 0, 0, domainBlock, &red, &blue,
	source_domain, gx, gy, domain_x, domain_y);
	
	// TODO: Compute new value
	
	int value= 0;
	new_value(source_domain, tx, ty, myself, &red, &blue, &value);
	
	// TODO: Write it in dest_domain
	dest_domain[ty * domain_x + tx] = value;
}

