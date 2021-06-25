#include "../include/table_operations.h"
#include <sys/time.h>


//头插法 
LinkedList headInsert(LinkedList *L,unsigned int tablesize){
	LinkedList p,s;
	(*L) = s = (LinkedList)malloc(sizeof(LNode));
	s->next = NULL;
	int num = 0;
	while(num < tablesize){
		p = (LinkedList)malloc(sizeof(LNode));
		p->data = num;
		p->next = s->next;
		s->next = p;
        num ++;
	}
	return s;
}

//尾插法
LinkedList tailInsert(LinkedList *L,unsigned int tablesize){
	LinkedList p,s;
	int num = 0;
	(*L) = s = (LinkedList)malloc(sizeof(LNode)); 
	s->next = NULL;
	while(num < tablesize){
		p = (LinkedList)malloc(sizeof(LNode));
		p->data = num;
		p->next = NULL;
		s->next = p;
		s = p;
		num ++;
	}
	return (*L);
} 

//给第k给结点之后增加一个值x
void  add(LinkedList L, int k, int x){
	int num;
	int i = 1;
	LinkedList p,s;
	p = L->next;
	for(i=1; i<k; i++){
		p = p->next;
	} 
	s = (LinkedList)malloc(sizeof(LNode));
	s->data = x;
	s->next = p->next;
	p->next = s;
}

//删除第k个结点
void deleteK(LinkedList L, int k){
	LinkedList p,q;
	int i = 1;
	p = L->next;
	for(i=1; i<k-1; i++){
		p = p->next;
	}
	q = p->next;
	p->next = q->next;
	free(q);
} 

//更改第k个结点的值为x
void update(LinkedList L, int k, int x){
	int i = 1;
	LinkedList p = L->next;
	for(i=1; i<k; i++){
		p = p->next;
	}
	p->data = x;
} 

//查询第k个结点的值 
int getK(LinkedList L, int k){
	int i = 1;
	LinkedList p = L->next;
	for(i=1; i<k; i++){
		p = p->next;
	} 
	return p->data;
}

//输出链表所有值 
void print(LinkedList L){
	LinkedList p = L->next;
	while(p){
		printf("%d\t", p->data);
		p = p->next;
	}
	printf("\n");
}

table_operations init_index_table(unsigned int tablesize)
{
    table_operations tops;
    tops.tablesize = tablesize;
    tops.idle_id_count = tablesize;

    index_table_entry *index_table = (index_table_entry *)calloc(tablesize, sizeof(index_table_entry));
    tops.index_table = index_table;

    LinkedList head = NULL;
    head = tailInsert(&head,tablesize);
    tops.idle_id_table = head;

    return tops;
}

int search_index_table(table_operations tablename, match_domain md)
{
    int tablesize = tablename.tablesize;
	int i = 0;
    for (i = 0; i < tablesize + 1; i++)
    {
        if(i == tablesize)
        {
            return -1;
        }
        else
        {
            if(cmp_tuples(tablename.index_table[i].md,md) == 1)
            {
                tablename.index_table[i].hit_count ++;
                return i;
            }
            else
            {
                continue;
            }
        }  
    }
}

// int search_index_table(table_operations *tablename, match_domain md)
// {
//     int tablesize = tablename->tablesize;
//     for (int i = 0; i < tablesize + 1; i++)
//     {
//         if(i == tablesize)
//         {
//             return -1;
//         }
//         else
//         {
//             if(cmp_tuples(tablename->index_table[i].md,md) == 1)
//             {
//                 tablename->index_table[i].hit_count ++;
//                 return i;
//             }
//             else
//             {
//                 continue;
//             }
//         }  
//     }
// }

int cmp_tuples(match_domain key1,match_domain key2)
{
    if (key1.protocol == key2.protocol)
    {
        if((key1.dst_ip == key2.dst_ip) && (key1.src_ip == key2.src_ip) && (key1.dst_port == key2.dst_port) && (key1.src_port == key2.src_port))
        {
            return 1;
        }    
    }
    else
    {
        return 0;
    }
}

int insert_new_entry(table_operations *tablename, match_domain md)
{
    if(tablename->idle_id_count == 0)
    {
        printf("FULL!\n");
        return 0;
    }
    else
    {
        //find pos to insert
        LinkedList p = tablename->idle_id_table->next->next;
        int pos = p->data;
        printf("____%d\n",pos);
        //write in index table
        index_table_entry temp;

        temp.md = md;
        struct timeval start;
        gettimeofday(&start,NULL);
        temp.time = start;
        temp.valid = 1;
        temp.hit_count = 0;
        tablename->index_table[pos] = temp;

        //update idle id count
        tablename->idle_id_count --;

        //update idle id table
        deleteK(tablename->idle_id_table,1);

        return pos;
    }
}

int delete_entry(table_operations *tablename, match_domain md)
{
    //int id = search_index_table(*tablename,md);
    int tablesize = tablename->tablesize;
    int id = 0;
	int i = 0;
    for (i = 0; i < tablesize + 1; i++)
    {
        if(i == tablesize)
        {
            id = -1;
        }
        else
        {
            if(cmp_tuples(tablename->index_table[i].md,md) == 1)
            {
                tablename->index_table[i].hit_count ++;
                id = i;
                break;
            }
            else
            {
                continue;
            }
        }  
    }
    printf("delete ___%d\n",id);

    if(id == -1)
    {
        printf("No entry!");
        return -1;
    }
    else
    {
        tablename->index_table[id].valid = 0;
        // idle 操作
        tablename->idle_id_count++;
        add(tablename->idle_id_table,tablesize-2,id);
        return 0;
    }
}

unsigned int get_idle_entry_num(table_operations tablename)
{
    return tablename.idle_id_count;
}

int get_table_entry_num(table_operations *tablename)
{
    return (tablename->tablesize)-(tablename->idle_id_count);
}

void print_entry_info(table_operations tablename,int entry_id)
{
    index_table_entry temp = tablename.index_table[entry_id];
    match_domain md = temp.md;
    struct timeval time = temp.time;
    unsigned int count = temp.hit_count;
    printf("==========================================================\n");
    printf("Valid: %d\n",temp.valid);
    printf("Tuples Info: %x %d %x %d %d\n",md.src_ip,md.src_port,md.dst_ip,md.dst_port,md.protocol);
//    printf("Time: %s",ctime((time_t *)&(time.tv_sec)));
    printf("HitCounter: %d\n",count);
    printf("==========================================================\n");
    //print(tablename.idle_id_table);
}
    

void free_index_table(table_operations *tablename)
{
    free(tablename->idle_id_table);
    free(tablename->index_table);
}